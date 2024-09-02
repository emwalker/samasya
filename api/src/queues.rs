mod chooser;

use crate::{
    types::{
        ApiError, ApiJson, ApiResponse, Approach, Cadence, Clock, OutcomeType, Queue,
        QueueStrategy, Result, Task, Timestamp,
    },
    ApiContext, PLACHOLDER_USER_ID,
};
use axum::{extract::Path, response::IntoResponse, Extension};
use chooser::Choose;
use chrono::Utc;
use hyper::StatusCode;
use serde::{Deserialize, Serialize};
use std::{fmt::Display, str::FromStr};
use tracing::info;
use uuid::Uuid;

pub type ListData = Vec<Queue>;

pub async fn list(
    ctx: Extension<ApiContext>,
    Path(user_id): Path<String>,
) -> Result<ApiJson<ApiResponse<ListData>>> {
    let data = crate::sqlx::queues::fetch_all(&ctx.db, &user_id, 20).await?;
    Ok(ApiJson(ApiResponse::data(data)))
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct AddPayload {
    pub strategy: QueueStrategy,
    pub summary: String,
    pub target_approach_id: String,
    pub cadence: Cadence,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct AddData {
    pub added_queue_id: String,
}

pub async fn add(
    ctx: Extension<ApiContext>,
    Path(user_id): Path<String>,
    ApiJson(payload): ApiJson<AddPayload>,
) -> Result<impl IntoResponse> {
    info!("user {}: adding queue: {:?}", user_id, payload);
    let id = uuid::Uuid::new_v4().to_string();

    if user_id != PLACHOLDER_USER_ID {
        return Err(ApiError::UnprocessableEntity(format!(
            "unknown user: {user_id}"
        )));
    }

    sqlx::query(
        "insert into queues (
            id, target_approach_id, summary, strategy, user_id, cadence
         )
         values ($1, $2, $3, $4, $5, $6)",
    )
    .bind(&id)
    .bind(&payload.target_approach_id)
    .bind(&payload.summary)
    .bind(payload.strategy.to_string())
    .bind(&user_id)
    .bind(payload.cadence.to_string())
    .execute(&ctx.db)
    .await?;

    Ok((
        StatusCode::CREATED,
        ApiJson(ApiResponse::data(AddData { added_queue_id: id })),
    ))
}

#[derive(Debug, Deserialize, Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct QueueOutcomeRow {
    task_name: String,
    approach_name: String,
    outcome_id: String,
    added_at: String,
    outcome: String,
    progress: u32,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct QueueOutcome {
    #[serde(flatten)]
    outcome: QueueOutcomeRow,
    task_available_at: String,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct FetchData {
    pub queue: QueueRow,
    pub outcomes: Vec<QueueOutcome>,
    pub target_problem: Task,
    pub target_approach: Approach,
}

pub async fn fetch(
    ctx: Extension<ApiContext>,
    Path(queue_id): Path<String>,
) -> Result<ApiJson<ApiResponse<FetchData>>> {
    let queue = sqlx::query_as::<_, QueueRow>("select * from queues where id = ?")
        .bind(&queue_id)
        .fetch_one(&ctx.db)
        .await?;

    let target_approach = sqlx::query_as::<_, Approach>("select * from approaches where id = ?")
        .bind(&queue.target_approach_id)
        .fetch_one(&ctx.db)
        .await?;

    let target_problem = sqlx::query_as::<_, Task>("select * from tasks where id = ?")
        .bind(&target_approach.task_id)
        .fetch_one(&ctx.db)
        .await?;

    let cadence = queue.cadence.parse::<Cadence>()?;
    let clock = Clock::now(cadence);

    let outcomes = sqlx::query_as::<_, QueueOutcomeRow>(
        "select
            t.summary task_summary,
            ap.summary approach_summary,
            o.id outcome_id,
            o.added_at,
            o.outcome,
            o.progress
         from outcomes o
         join tasks t on ap.task_id = t.id
         join approaches ap on o.approach_id = ap.id
         where o.user_id = ? and o.queue_id = ?
         order by o.added_at desc
         limit 15",
    )
    .bind(PLACHOLDER_USER_ID)
    .bind(&queue_id)
    .fetch_all(&ctx.db)
    .await?;

    let outcomes = outcomes
        .into_iter()
        .map(|outcome| {
            let state = outcome.outcome.parse::<OutcomeType>()?;
            let added_at = outcome.added_at.parse::<Timestamp>()?;
            let task_available_at: String = state
                .next_available_at(&clock, &added_at, outcome.progress)?
                .to_iso_8601();
            Ok(QueueOutcome {
                outcome,
                task_available_at,
            })
        })
        .collect::<Result<Vec<_>>>()?;

    Ok(ApiJson(ApiResponse::data(FetchData {
        queue,
        outcomes,
        target_problem,
        target_approach,
    })))
}

impl FromStr for OutcomeType {
    type Err = ApiError;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        match s {
            "completed" => Ok(Self::Completed),
            "needsRetry" => Ok(Self::NeedsRetry),
            "tooHard" => Ok(Self::TooHard),
            _ => Err(ApiError::General(format!("unknown answer state: {s}"))),
        }
    }
}

impl Display for OutcomeType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let value = match self {
            Self::Completed => "completed",
            Self::NeedsRetry => "needsRetry",
            Self::TooHard => "tooHard",
        };
        write!(f, "{}", value)
    }
}

#[derive(Debug, Deserialize, Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct QueueRow {
    pub summary: String,
    pub strategy: String,
    pub cadence: String,
    #[serde(skip)]
    pub target_approach_id: Option<String>,
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

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase", tag = "outcome")]
enum NextProblem {
    EmptyQueue,

    #[serde(rename_all = "camelCase")]
    NotReady {
        available_at: Timestamp,
    },

    #[serde(rename_all = "camelCase")]
    Ready {
        available_at: Timestamp,
        approach_id: String,
    },
}

#[allow(dead_code)]
#[derive(Debug)]
struct OutcomeData {
    progress: u32,
    added_at: Timestamp,
    state: OutcomeType,
}

#[allow(dead_code)]
#[derive(Debug)]
struct Outcome {
    approach_id: String,
    data: Option<OutcomeData>,
}

#[derive(sqlx::FromRow)]
struct OutcomeRow {
    #[allow(unused)]
    task_id: String,
    approach_id: String,
    added_at: Option<String>,
    progress: Option<u32>,
    outcome: Option<String>,
}

impl TryFrom<OutcomeRow> for Outcome {
    type Error = ApiError;

    fn try_from(
        OutcomeRow {
            approach_id,
            added_at,
            progress,
            outcome,
            ..
        }: OutcomeRow,
    ) -> std::result::Result<Self, Self::Error> {
        let Some(answered_at) = added_at else {
            return Ok(Outcome {
                approach_id: approach_id.clone(),
                data: None,
            });
        };
        let answered_at = answered_at.parse::<Timestamp>()?;

        let Some(progress) = progress else {
            return Ok(Outcome {
                approach_id: approach_id.clone(),
                data: None,
            });
        };

        let Some(outcome) = outcome else {
            return Ok(Outcome {
                approach_id: approach_id.clone(),
                data: None,
            });
        };
        let state = outcome.parse::<OutcomeType>()?;

        Ok(Outcome {
            approach_id: approach_id.clone(),
            data: Some(OutcomeData {
                added_at: answered_at,
                progress,
                state,
            }),
        })
    }
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct NextTaskData {
    queue: QueueRow,
    task: Option<Task>,
    approach: Option<Approach>,
    #[serde(flatten)]
    details: NextProblem,
}

pub async fn next_task(
    ctx: Extension<ApiContext>,
    Path(queue_id): Path<String>,
) -> Result<ApiJson<ApiResponse<NextTaskData>>> {
    let queue = sqlx::query_as::<_, QueueRow>("select * from queues where id = ?")
        .bind(&queue_id)
        .fetch_one(&ctx.db)
        .await?;

    info!("fetching history for queue {queue_id} ...");
    // Problems that must be mastered for the skills needed for the target problem
    let history = sqlx::query_as::<_, OutcomeRow>(
        "select
                ap.prereq_approach_id approach_id,
                o.added_at,
                o.outcome,
                o.progress
             from approach_prereqs ap
             left join outcomes o
                on o.user_id = ?
                and o.queue_id = ?
                and ap.prereq_approach_id = o.approach_id
             where ap.approach_id = ?",
    )
    .bind(PLACHOLDER_USER_ID)
    .bind(&queue_id)
    .bind(&queue.target_approach_id)
    .fetch_all(&ctx.db)
    .await?;

    let history = history
        .into_iter()
        .map(Outcome::try_from)
        .collect::<Result<Vec<_>>>()?;

    let cadence = queue.cadence.parse::<Cadence>()?;
    let clock = Clock::now(cadence);
    let strategy = queue.strategy.parse::<QueueStrategy>()?;
    let next = strategy.choose(clock, &history)?;

    let (task, approach) = match &next {
        NextProblem::Ready { approach_id, .. } => {
            let approach = sqlx::query_as::<_, Approach>("select * from approaches where id = ?")
                .bind(approach_id)
                .fetch_one(&ctx.db)
                .await?;

            let task = sqlx::query_as::<_, Task>("select * from tasks where id = ?")
                .bind(&approach.task_id)
                .fetch_one(&ctx.db)
                .await?;

            (Some(task), Some(approach))
        }

        _ => (None, None),
    };

    Ok(ApiJson(ApiResponse::data(NextTaskData {
        queue,
        task,
        approach,
        details: next,
    })))
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct AddOutcomeData {
    answer_id: String,
    message: String,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AddOutcomePayload {
    queue_id: String,
    approach_id: String,
    outcome: OutcomeType,
}

pub async fn add_outcome(
    ctx: Extension<ApiContext>,
    Path(path_queue_id): Path<String>,
    ApiJson(AddOutcomePayload {
        queue_id,
        approach_id,
        outcome,
    }): ApiJson<AddOutcomePayload>,
) -> Result<ApiJson<ApiResponse<AddOutcomeData>>> {
    if path_queue_id != queue_id {
        return Err(ApiError::UnprocessableEntity(String::from(
            "queue id must match the payload",
        )));
    }

    let prev_progress = sqlx::query_as::<_, (u32,)>(
        "select progress
         from outcomes
         where user_id = ? and queue_id = ? and approach_id = ?
         order by added_at desc
         limit 1",
    )
    .bind(PLACHOLDER_USER_ID)
    .bind(&queue_id)
    .bind(&approach_id)
    .fetch_optional(&ctx.db)
    .await?
    .unwrap_or_default()
    .0;

    let progress = match &outcome {
        OutcomeType::Completed => prev_progress.saturating_add(1),
        _ => prev_progress.saturating_sub(1),
    };

    let new_id: String = Uuid::new_v4().into();
    let answer_state: String = outcome.to_string();
    let added_at = Utc::now();

    let (answer_id,) = sqlx::query_as::<_, (String,)>(
        "insert into outcomes (
            user_id, id, added_at, answered_at, approach_id, queue_id, outcome,
            progress
         )
         values (?, ?, ?, ?, ?, ?, ?, ?, ?)
         returning id",
    )
    .bind(PLACHOLDER_USER_ID)
    .bind(&new_id)
    .bind(added_at)
    .bind(added_at)
    .bind(&approach_id)
    .bind(&queue_id)
    .bind(&answer_state)
    .bind(progress)
    .fetch_one(&ctx.db)
    .await?;

    Ok(ApiJson(ApiResponse::data(AddOutcomeData {
        answer_id,
        message: String::from("ok"),
    })))
}
