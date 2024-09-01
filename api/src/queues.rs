mod chooser;

use crate::{
    types::{
        AnswerState, ApiError, ApiJson, ApiResponse, Approach, Problem, Queue, QueueStrategy,
        Result, Timestamp,
    },
    ApiContext, PLACHOLDER_USER_ID,
};
use axum::{extract::Path, Extension};
use chooser::Choose;
use chrono::{TimeDelta, Utc};
use serde::{Deserialize, Serialize};
use std::{fmt::Display, str::FromStr};
use tracing::info;
use uuid::Uuid;

pub async fn list(
    ctx: Extension<ApiContext>,
    Path(user_id): Path<String>,
) -> Result<ApiJson<ApiResponse<Vec<Queue>>>> {
    let data = crate::sqlx::queues::fetch_all(&ctx.db, &user_id, 20).await?;
    Ok(ApiJson(ApiResponse::data(data)))
}

#[derive(Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct UpdatePayload {
    strategy: QueueStrategy,
    summary: String,
    target_problem_id: String,
}

pub async fn add(
    ctx: Extension<ApiContext>,
    Path(user_id): Path<String>,
    ApiJson(update): ApiJson<UpdatePayload>,
) -> Result<ApiJson<ApiResponse<String>>> {
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
    .bind(update.strategy.to_string())
    .bind(&update.target_problem_id)
    .bind(&user_id)
    .bind(created_at)
    .bind(created_at)
    .execute(&ctx.db)
    .await?;

    Ok(ApiJson::ok())
}

#[derive(Debug, Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct QueueAnswer {
    problem_summary: String,
    approach_name: Option<String>,
    answer_id: String,
    answer_answered_at: String,
    answer_state: String,
    answer_consecutive_correct: u32,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct FetchData {
    queue: QueueRow,
    answers: Vec<QueueAnswer>,
    target_problem: Problem,
    target_approach: Option<Approach>,
}

pub async fn fetch(
    ctx: Extension<ApiContext>,
    Path(queue_id): Path<String>,
) -> Result<ApiJson<ApiResponse<FetchData>>> {
    let queue = sqlx::query_as::<_, QueueRow>("select * from queues where id = ?")
        .bind(&queue_id)
        .fetch_one(&ctx.db)
        .await?;

    let target_problem = sqlx::query_as::<_, Problem>("select * from problems where id = ?")
        .bind(&queue.target_problem_id)
        .fetch_one(&ctx.db)
        .await?;

    let target_approach = if let Some(approach_id) = &queue.target_approach_id {
        let approach = sqlx::query_as::<_, Approach>("select * from approaches where id = ?")
            .bind(approach_id)
            .fetch_one(&ctx.db)
            .await?;
        Some(approach)
    } else {
        None
    };

    let answers = sqlx::query_as::<_, QueueAnswer>(
        "select
            p.summary problem_summary,
            ap.name approach_name,
            a.id answer_id,
            a.answered_at answer_answered_at,
            a.state answer_state,
            a.consecutive_correct answer_consecutive_correct
         from answers a
         join problems p on a.problem_id = p.id
         left join approaches ap on a.approach_id = ap.id
         where a.user_id = ? and a.queue_id = ?
         order by a.answered_at desc
         limit 15",
    )
    .bind(PLACHOLDER_USER_ID)
    .bind(&queue_id)
    .fetch_all(&ctx.db)
    .await?;

    Ok(ApiJson(ApiResponse::data(FetchData {
        queue,
        answers,
        target_problem,
        target_approach,
    })))
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

impl Display for AnswerState {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let value = match self {
            Self::Unseen => "unseen",
            Self::Unsure => "unsure",
            Self::Correct => "correct",
            Self::Incorrect => "incorrect",
        };
        write!(f, "{}", value)
    }
}

#[derive(Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
struct QueueRow {
    summary: String,
    strategy: String,
    cadence: String,
    #[serde(skip)]
    target_problem_id: String,
    #[serde(skip)]
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

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase", tag = "status")]
enum NextProblem {
    EmptyQueue,

    #[serde(rename_all = "camelCase")]
    NotReady {
        available_at: Timestamp,
    },

    #[serde(rename_all = "camelCase")]
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

#[derive(Clone, Copy, Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
enum Cadence {
    Minutes,
    Hours,
}

impl FromStr for Cadence {
    type Err = ApiError;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        match s {
            "minutes" => Ok(Self::Minutes),
            "hours" => Ok(Self::Hours),
            _ => Err(ApiError::UnprocessableEntity(format!(
                "unknown cadence: {s}"
            ))),
        }
    }
}

#[derive(Debug)]
struct Clock {
    now: Timestamp,
    cadence: Cadence,
}

impl Clock {
    #[allow(dead_code)]
    fn new(cadence: Cadence) -> Self {
        Self {
            now: Timestamp::from_timestamp(0).unwrap(),
            cadence,
        }
    }

    fn now(cadence: Cadence) -> Self {
        Self {
            now: Timestamp::now(),
            cadence,
        }
    }

    #[allow(dead_code)]
    fn ticks(&self, n: i32) -> Option<Self> {
        let ticks = self.one_tick().checked_mul(n)?;
        let now = self.now.checked_add_signed(ticks)?;

        Some(Self {
            now,
            cadence: self.cadence,
        })
    }

    #[allow(dead_code)]
    fn one_tick(&self) -> TimeDelta {
        match self.cadence {
            Cadence::Minutes => TimeDelta::minutes(1),
            Cadence::Hours => TimeDelta::hours(1),
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
                problem_id: problem_id.clone(),
                approach_id,
                data: None,
            });
        };
        let answered_at = answered_at.parse::<Timestamp>()?;

        let Some(consecutive_correct) = consecutive_correct else {
            return Ok(AnsweredProblem {
                problem_id: problem_id.clone(),
                approach_id,
                data: None,
            });
        };

        let Some(state) = state else {
            return Ok(AnsweredProblem {
                problem_id: problem_id.clone(),
                approach_id,
                data: None,
            });
        };
        let state = state.parse::<AnswerState>()?;

        Ok(AnsweredProblem {
            problem_id: problem_id.clone(),
            approach_id,
            data: Some(AnswerData {
                answered_at,
                consecutive_correct,
                state,
            }),
        })
    }
}

#[derive(Serialize)]
pub struct NextProblemData {
    queue: QueueRow,
    problem: Option<Problem>,
    approach: Option<Approach>,
    #[serde(flatten)]
    details: NextProblem,
}

pub async fn next_problem(
    ctx: Extension<ApiContext>,
    Path(queue_id): Path<String>,
) -> Result<ApiJson<ApiResponse<NextProblemData>>> {
    let queue = sqlx::query_as::<_, QueueRow>("select * from queues where id = ?")
        .bind(&queue_id)
        .fetch_one(&ctx.db)
        .await?;

    info!("fetching history for queue {queue_id} ...");
    // Problems that must be mastered for the skills needed for the target problem
    let history = if let Some(approach_id) = &queue.target_approach_id {
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
                on a.user_id = ?
                and a.queue_id = ?
                and pp.prereq_problem_id = a.problem_id
                and pp.prereq_approach_id = a.approach_id
             where ps.problem_id = ? and ps.approach_id = ?",
        )
        .bind(PLACHOLDER_USER_ID)
        .bind(&queue_id)
        .bind(&queue.target_problem_id)
        .bind(approach_id)
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
                on a.user_id = ?
                and a.queue_id = ?
                and a.problem_id = pp.prereq_problem_id
                and a.approach_id is null
             where ps.problem_id = ? and ps.approach_id is null",
        )
        .bind(PLACHOLDER_USER_ID)
        .bind(&queue_id)
        .bind(&queue.target_problem_id)
        .fetch_all(&ctx.db)
        .await?
    };
    let history = history
        .into_iter()
        .map(AnsweredProblem::try_from)
        .collect::<Result<Vec<_>>>()?;

    let cadence = queue.cadence.parse::<Cadence>()?;
    let clock = Clock::now(cadence);
    let strategy = queue.strategy.parse::<QueueStrategy>()?;
    let next = strategy.choose(clock, &history)?;

    let (problem, approach) = match &next {
        NextProblem::Ready {
            problem_id,
            approach_id,
            ..
        } => {
            let problem = sqlx::query_as::<_, Problem>("select * from problems where id = ?")
                .bind(problem_id)
                .fetch_one(&ctx.db)
                .await?;

            let approach = if let Some(approach_id) = approach_id {
                sqlx::query_as::<_, Approach>("select * from approaches where id = ?")
                    .bind(approach_id)
                    .fetch_optional(&ctx.db)
                    .await?
            } else {
                None
            };

            (Some(problem), approach)
        }

        _ => (None, None),
    };

    Ok(ApiJson(ApiResponse::data(NextProblemData {
        queue,
        problem,
        approach,
        details: next,
    })))
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct AddAnswerData {
    answer_id: String,
    message: String,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AddAnswerPayload {
    queue_id: String,
    problem_id: String,
    approach_id: Option<String>,
    answer_state: AnswerState,
}

pub async fn add_answer(
    ctx: Extension<ApiContext>,
    Path(path_queue_id): Path<String>,
    ApiJson(AddAnswerPayload {
        queue_id,
        problem_id,
        approach_id,
        answer_state,
    }): ApiJson<AddAnswerPayload>,
) -> Result<ApiJson<ApiResponse<AddAnswerData>>> {
    if path_queue_id != queue_id {
        return Err(ApiError::UnprocessableEntity(String::from(
            "queue id must match the payload",
        )));
    }

    let prev_consecutive_correct = if let Some(approach_id) = &approach_id {
        sqlx::query_as::<_, (u32,)>(
            "select consecutive_correct
             from answers
             where user_id = ? and queue_id = ? and problem_id = ? and approach_id = ?
             order by added_at desc
             limit 1",
        )
        .bind(PLACHOLDER_USER_ID)
        .bind(&queue_id)
        .bind(&problem_id)
        .bind(approach_id)
        .fetch_optional(&ctx.db)
        .await?
    } else {
        sqlx::query_as::<_, (u32,)>(
            "select consecutive_correct
             from answers
             where user_id = ? and queue_id = ? and problem_id = ? and approach_id is null
             order by added_at desc
             limit 1",
        )
        .bind(PLACHOLDER_USER_ID)
        .bind(&queue_id)
        .bind(&problem_id)
        .fetch_optional(&ctx.db)
        .await?
    }
    .unwrap_or_default()
    .0;

    let consecutive_correct = match &answer_state {
        AnswerState::Correct => prev_consecutive_correct.saturating_add(1),
        _ => prev_consecutive_correct.saturating_sub(1),
    };

    let new_id: String = Uuid::new_v4().into();
    let answer_state: String = answer_state.to_string();
    let added_at = Utc::now();

    let (answer_id,) = sqlx::query_as::<_, (String,)>(
        "insert into answers (
            user_id, id, added_at, answered_at, problem_id, approach_id, queue_id, state,
            consecutive_correct
         )
         values (?, ?, ?, ?, ?, ?, ?, ?, ?)
         returning id",
    )
    .bind(PLACHOLDER_USER_ID)
    .bind(&new_id)
    .bind(added_at)
    .bind(added_at)
    .bind(&problem_id)
    .bind(&approach_id)
    .bind(&queue_id)
    .bind(&answer_state)
    .bind(consecutive_correct)
    .fetch_one(&ctx.db)
    .await?;

    Ok(ApiJson(ApiResponse::data(AddAnswerData {
        answer_id,
        message: String::from("ok"),
    })))
}