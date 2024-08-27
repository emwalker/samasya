use crate::{
    types::{Approach, Result, WideApproach},
    ApiContext,
};
use axum::{extract::Path, Extension, Json};
use serde::{Deserialize, Serialize};
use serde_json::json;
use tracing::info;

#[derive(Deserialize, Serialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct UpdatePayload {
    name: String,
    problem_id: String,
    prereq_approach_ids: Vec<String>,
    prereq_skill_ids: Vec<String>,
}

pub async fn add(
    ctx: Extension<ApiContext>,
    Json(update): Json<UpdatePayload>,
) -> Result<Json<serde_json::Value>> {
    info!("adding approach: {:?}", update);
    let id = uuid::Uuid::new_v4().to_string();

    sqlx::query("insert into approaches (id, problem_id, name) values ($1, $2, $3)")
        .bind(&id)
        .bind(&update.problem_id)
        .bind(&update.name)
        .execute(&ctx.db)
        .await?;

    for prereq_id in update.prereq_skill_ids {
        sqlx::query("insert into prereq_skills (approach_id, prereq_skill_id) values ($1, $2)")
            .bind(&id)
            .bind(&prereq_id)
            .execute(&ctx.db)
            .await?;
    }

    for prereq_id in update.prereq_approach_ids {
        sqlx::query(
            "insert into prereq_problems (problem_id, prereq_approach_id)
             values ($1, $2)",
        )
        .bind(&id)
        .bind(&prereq_id)
        .execute(&ctx.db)
        .await?;
    }

    Ok(Json(json!({})))
}

pub async fn update(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
    Json(update): Json<UpdatePayload>,
) -> Result<Json<serde_json::Value>> {
    sqlx::query("update approaches set name = $1 where id = $2")
        .bind(&update.name)
        .bind(&id)
        .execute(&ctx.db)
        .await?;

    sqlx::query("delete from prereq_skills where approach_id = $1")
        .bind(&id)
        .execute(&ctx.db)
        .await?;

    for skill_id in update.prereq_skill_ids {
        sqlx::query("insert into prereq_skills (approach_id, prereq_skill_id) values ($1, $2)")
            .bind(&id)
            .bind(&skill_id)
            .execute(&ctx.db)
            .await?;
    }

    sqlx::query("delete from prereq_approaches where approach_id = $1")
        .bind(&id)
        .execute(&ctx.db)
        .await?;

    for prereq_id in update.prereq_approach_ids {
        sqlx::query(
            "insert into prereq_approaches (approach_id, prereq_approach_id)
             values ($1, $2)",
        )
        .bind(&id)
        .bind(&prereq_id)
        .execute(&ctx.db)
        .await?;
    }

    Ok(Json(json!({})))
}

#[derive(Serialize)]
pub struct ApproachResponse {
    data: WideApproach,
}

pub async fn fetch(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
) -> Result<Json<ApproachResponse>> {
    let data = crate::sqlx::approaches::fetch_wide(&ctx.db, &id).await?;
    Ok(Json(ApproachResponse { data }))
}

#[derive(Serialize)]
pub struct ApproachListResponse {
    data: Vec<Approach>,
}

pub async fn list(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
) -> Result<Json<ApproachListResponse>> {
    let problem_id = id;
    let data = crate::sqlx::approaches::fetch_all(&ctx.db, &problem_id, 20).await?;
    Ok(Json(ApproachListResponse { data }))
}
