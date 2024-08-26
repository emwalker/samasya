use crate::{
    sqlx::queues::QueueResult,
    types::{ApiErrorResponse, Queue, QueueStrategy},
    ApiContext, ApiJson, Result,
};
use axum::{extract::Path, Extension, Json};
use serde::{Deserialize, Serialize};
use tracing::info;

#[derive(Serialize)]
pub struct QueuesListResponse {
    data: Vec<Queue>,
}

pub async fn list(
    ctx: Extension<ApiContext>,
    Path(user_id): Path<String>,
) -> Result<Json<QueuesListResponse>> {
    let data = crate::sqlx::queues::fetch_all(&ctx.db, &user_id, 20).await?;
    Ok(Json(QueuesListResponse { data }))
}

#[derive(Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct QueueUpdate {
    strategy: QueueStrategy,
    summary: String,
    target_problem_id: String,
}

#[derive(Serialize)]
pub struct UpdateQueueResponse {
    data: Option<String>,
    errors: Vec<ApiErrorResponse>,
}

impl UpdateQueueResponse {
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
    ApiJson(update): ApiJson<QueueUpdate>,
) -> Result<Json<UpdateQueueResponse>> {
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

    Ok(Json(UpdateQueueResponse::ok()))
}

#[derive(Serialize)]
pub struct QueueResponse {
    data: QueueResult,
}

pub async fn get(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
) -> Result<Json<QueueResponse>> {
    let result = crate::sqlx::queues::fetch_wide(&ctx.db, &id).await?;
    Ok(Json(QueueResponse { data: result }))
}
