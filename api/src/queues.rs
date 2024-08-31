mod chooser;

use std::str::FromStr;

use crate::{
    sqlx::queues::QueueResult,
    types::{ApiError, ApiErrorResponse, Queue, QueueStrategy, Result, Timestamp},
    ApiContext, ApiJson,
};
use axum::{extract::Path, Extension, Json};
use chooser::{Choose, SpacedRepetitionV1};
use chrono::TimeDelta;
use serde::{Deserialize, Serialize};
use tracing::info;

#[derive(Serialize)]
pub struct ListResponse {
    data: Vec<Queue>,
}

pub async fn list(
    ctx: Extension<ApiContext>,
    Path(user_id): Path<String>,
) -> Result<Json<ListResponse>> {
    let data = crate::sqlx::queues::fetch_all(&ctx.db, &user_id, 20).await?;
    Ok(Json(ListResponse { data }))
}

#[derive(Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct UpdatePayload {
    strategy: QueueStrategy,
    summary: String,
    target_problem_id: String,
}

#[derive(Serialize)]
pub struct UpdateResponse {
    data: Option<String>,
    errors: Vec<ApiErrorResponse>,
}

impl UpdateResponse {
    fn ok() -> Self {
        Self {
            data: None,
            errors: vec![],
        }
    }
}

pub async fn add(
    ctx: Extension<ApiContext>,
    Path(user_id): Path<String>,
    ApiJson(update): ApiJson<UpdatePayload>,
) -> Result<Json<UpdateResponse>> {
    info!("user {}: adding queue: {:?}", user_id, update);
    let id = uuid::Uuid::new_v4().to_string();
    let created_at = chrono::Utc::now();

    sqlx::query(
        "insert into queues (
            id, summary, strategy, target_problem_id, user_id, created_at, updated_at
         )
         values ($1, $2, $3, $4, $5, $6, $7)",
    )
    .bind(&id)
    .bind(&update.summary)
    .bind(update.strategy as i32)
    .bind(&update.target_problem_id)
    .bind(&user_id)
    .bind(created_at)
    .bind(created_at)
    .execute(&ctx.db)
    .await?;

    Ok(Json(UpdateResponse::ok()))
}

#[derive(Serialize)]
pub struct FetchResponse {
    data: QueueResult,
}

pub async fn fetch(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
) -> Result<Json<FetchResponse>> {
    let result = crate::sqlx::queues::fetch_wide(&ctx.db, &id).await?;
    Ok(Json(FetchResponse { data: result }))
}

#[derive(Debug, Deserialize)]
enum AnswerState {
    Unseen,
    Unsure,
    Correct,
    Incorrect,
}

impl FromStr for AnswerState {
    type Err = ApiError;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        match s {
            "unseen" => Ok(Self::Unseen),
            "unsure" => Ok(Self::Unsure),
            "correct" => Ok(Self::Correct),
            "incorrect" => Ok(Self::Incorrect),
            _ => Err(ApiError::General(format!("unknown answer state: {s}"))),
        }
    }
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
enum NextProblem {
    EmptyQueue,

    NotReady {
        available_at: Timestamp,
    },

    Ready {
        available_at: Timestamp,
        problem_id: String,
        approach_id: Option<String>,
    },
}

#[allow(dead_code)]
#[derive(Debug)]
struct AnswerData {
    consecutive_correct: u32,
    answered_at: Timestamp,
    state: AnswerState,
}

#[allow(dead_code)]
#[derive(Debug)]
struct AnsweredProblem {
    problem_id: String,
    approach_id: Option<String>,
    data: Option<AnswerData>,
}

#[allow(dead_code)]
#[derive(Clone, Copy, Debug)]
enum Tick {
    Minutes,
    Hours,
}

#[allow(dead_code)]
#[derive(Debug)]
struct Clock {
    now: Timestamp,
    unit: Tick,
}

impl Clock {
    #[allow(dead_code)]
    fn new(unit: Tick) -> Self {
        Self {
            now: Timestamp::from_timestamp(0).unwrap(),
            unit,
        }
    }

    fn now(unit: Tick) -> Self {
        Self {
            now: Timestamp::now(),
            unit,
        }
    }

    #[allow(dead_code)]
    fn ticks(&self, n: i32) -> Option<Self> {
        let ticks = self.one_tick().checked_mul(n)?;
        let now = self.now.checked_add_signed(ticks)?;

        Some(Self {
            now,
            unit: self.unit,
        })
    }

    #[allow(dead_code)]
    fn one_tick(&self) -> TimeDelta {
        match self.unit {
            Tick::Minutes => TimeDelta::minutes(1),
            Tick::Hours => TimeDelta::hours(1),
        }
    }
}

#[derive(sqlx::FromRow)]
struct AnsweredProblemRow {
    problem_id: String,
    approach_id: Option<String>,
    answered_at: Option<String>,
    consecutive_correct: Option<u32>,
    state: Option<String>,
}

impl TryFrom<AnsweredProblemRow> for AnsweredProblem {
    type Error = ApiError;

    fn try_from(
        AnsweredProblemRow {
            problem_id,
            approach_id,
            answered_at,
            consecutive_correct,
            state,
        }: AnsweredProblemRow,
    ) -> std::result::Result<Self, Self::Error> {
        let Some(answered_at) = answered_at else {
            return Ok(AnsweredProblem {
                problem_id,
                approach_id,
                data: None,
            });
        };
        let answered_at = answered_at.parse::<Timestamp>()?;

        let Some(consecutive_correct) = consecutive_correct else {
            return Ok(AnsweredProblem {
                problem_id,
                approach_id,
                data: None,
            });
        };

        let Some(state) = state else {
            return Ok(AnsweredProblem {
                problem_id,
                approach_id,
                data: None,
            });
        };
        let state = state.parse::<AnswerState>()?;

        Ok(AnsweredProblem {
            problem_id,
            approach_id,
            data: Some(AnswerData {
                answered_at,
                consecutive_correct,
                state,
            }),
        })
    }
}

#[derive(sqlx::FromRow)]
struct QueueRow {
    target_problem_id: String,
    target_approach_id: Option<String>,
}

#[derive(sqlx::FromRow, Serialize)]
#[serde(rename_all = "camelCase")]
struct PrereqProblem {
    prereq_skill_id: String,
    prereq_problem_id: String,
    prereq_problem_summary: String,
    prereq_approach_id: Option<String>,
    prereq_approach_name: Option<String>,
}

#[derive(Serialize)]
pub struct NextProblemResponse {
    data: Option<NextProblem>,
    errors: Vec<ApiErrorResponse>,
}

pub async fn next_problem(
    ctx: Extension<ApiContext>,
    Path(queue_id): Path<String>,
) -> Result<ApiJson<NextProblemResponse>> {
    let queue = sqlx::query_as::<_, QueueRow>("select * from queues where id = ?")
        .bind(&queue_id)
        .fetch_one(&ctx.db)
        .await?;

    info!("fetching history for queue {queue_id} ...");
    // Problems that must be mastered for the skills needed for the target problem
    let history = if let Some(approach_id) = queue.target_approach_id {
        sqlx::query_as::<_, AnsweredProblemRow>(
            "select
                pp.prereq_problem_id problem_id,
                pp.prereq_approach_id approach_id,
                a.answered_at,
                a.state,
                a.consecutive_correct
             from prereq_skills ps
             join prereq_problems pp on pp.skill_id = ps.prereq_skill_id
             join problems p on p.id = pp.prereq_problem_id
             left join answers a
                on pp.prereq_problem_id = a.problem_id
                and pp.prereq_approach_id = a.approach_id
             where ps.problem_id = ? and ps.approach_id = ?
                and (a.queue_id is null or a.queue_id = ?)",
        )
        .bind(&queue.target_problem_id)
        .bind(&approach_id)
        .bind(&queue_id)
        .fetch_all(&ctx.db)
        .await?
    } else {
        sqlx::query_as::<_, AnsweredProblemRow>(
            "select
                pp.prereq_problem_id problem_id,
                pp.prereq_approach_id approach_id,
                a.answered_at,
                a.state,
                a.consecutive_correct
             from prereq_skills ps
             join prereq_problems pp on pp.skill_id = ps.prereq_skill_id
             join problems p on p.id = pp.prereq_problem_id
             left join answers a
                on pp.prereq_problem_id = a.problem_id
                and pp.prereq_approach_id = a.approach_id
             where ps.problem_id = ?
                and (a.queue_id is null or a.queue_id = ?)",
        )
        .bind(&queue.target_problem_id)
        .bind(&queue_id)
        .fetch_all(&ctx.db)
        .await?
    };
    let history = history
        .into_iter()
        .map(AnsweredProblem::try_from)
        .collect::<Result<Vec<_>>>()?;

    let clock = Clock::now(Tick::Minutes);
    let next_problem = SpacedRepetitionV1.choose(clock, &history)?;

    Ok(ApiJson(NextProblemResponse {
        data: Some(next_problem),
        errors: vec![],
    }))
}
