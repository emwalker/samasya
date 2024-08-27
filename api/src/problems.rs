use crate::{
    types::{ApiError, Problem, Result, WideProblem},
    ApiContext,
};
use axum::{
    extract::{Path, Query},
    Extension, Json,
};
use serde::{Deserialize, Serialize};
use serde_json::json;
use tracing::info;

#[derive(Serialize)]
pub struct FetchResponse {
    data: WideProblem,
}

pub async fn fetch(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
) -> Result<Json<FetchResponse>> {
    let data = crate::sqlx::problems::fetch_wide(&ctx.db, &id).await?;
    Ok(Json(FetchResponse { data }))
}

#[derive(Debug, Default, Deserialize)]
pub struct Search {
    q: String,
}

impl Search {
    pub(crate) fn is_empty(&self) -> bool {
        self.q.is_empty()
    }

    pub(crate) fn substrings(&self) -> impl Iterator<Item = &str> + '_ {
        self.q.split_whitespace()
    }
}

#[derive(Serialize)]
pub struct ListResponse {
    data: Vec<Problem>,
}

pub async fn list(
    ctx: Extension<ApiContext>,
    search: Option<Query<Search>>,
) -> Result<Json<ListResponse>> {
    let search = search.unwrap_or_default().0;
    info!("searching problems: {:?}", search);
    let data = crate::sqlx::problems::list(&ctx.db, 20, search).await?;
    Ok(Json(ListResponse { data }))
}

fn ensure_valid_problem_update(
    update: UpdatePayload,
) -> Result<(String, Option<String>, Option<String>)> {
    let UpdatePayload {
        mut question_text,
        mut question_url,
        summary,
    } = update;

    if summary.is_empty() {
        return Err(ApiError::UnprocessableEntity(
            "a summary is required".into(),
        ));
    }

    if let Some(inner) = &question_text {
        if inner.is_empty() {
            question_text = None;
        }
    }

    if let Some(inner) = &question_url {
        if inner.is_empty() {
            question_url = None;
        }
    }

    if question_text.is_none() && question_url.is_none() {
        return Err(ApiError::UnprocessableEntity(
            "either a question prompt or a question url is required".into(),
        ));
    }

    if question_text.is_some() && question_url.is_some() {
        return Err(ApiError::UnprocessableEntity(
            "a question prompt and a question url cannot be provided together".into(),
        ));
    }

    Ok((summary, question_text, question_url))
}

#[derive(Deserialize, Serialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct UpdatePayload {
    question_text: Option<String>,
    question_url: Option<String>,
    summary: String,
}

pub async fn add(
    ctx: Extension<ApiContext>,
    Json(update): Json<UpdatePayload>,
) -> Result<Json<serde_json::Value>> {
    info!("adding problem: {:?}", update);
    let id = uuid::Uuid::new_v4().to_string();

    let (summary, question_text, question_url) = ensure_valid_problem_update(update)?;

    sqlx::query(
        "insert into problems (id, summary, question_text, question_url) values ($1, $2, $3, $4)",
    )
    .bind(&id)
    .bind(&summary)
    .bind(&question_text)
    .bind(&question_url)
    .execute(&ctx.db)
    .await?;

    Ok(Json(json!({})))
}

pub async fn update(
    ctx: Extension<ApiContext>,
    Path(problem_id): Path<String>,
    Json(update): Json<UpdatePayload>,
) -> Result<Json<serde_json::Value>> {
    info!("updating problem: {:?}", update);

    let (summary, question_text, question_url) = ensure_valid_problem_update(update)?;

    sqlx::query(
        "update problems set summary = $1, question_text = $2, question_url = $3 where id = $4",
    )
    .bind(&summary)
    .bind(&question_text)
    .bind(&question_url)
    .bind(&problem_id)
    .execute(&ctx.db)
    .await?;

    Ok(Json(json!({})))
}
