use crate::{
    types::{ApiError, ApiJson, ApiOk, ApiResponse, Approach, Result, Search, Task, TaskAction},
    ApiContext, PLACEHOLDER_USER_ID,
};
use axum::{
    extract::{Path, Query},
    Extension,
};
use serde::{Deserialize, Serialize};
use tracing::info;
use uuid::Uuid;

#[derive(Debug, Deserialize, Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
struct PrereqSkill {
    problem_id: String,
    approach_id: Option<String>,
    prereq_skill_id: String,
    prereq_skill_summary: String,
}

#[derive(sqlx::FromRow)]
pub(crate) struct TaskRow {
    id: String,
    summary: String,
    action: String,
    question_prompt: Option<String>,
    question_url: Option<String>,
}

impl TryFrom<TaskRow> for Task {
    type Error = ApiError;

    fn try_from(row: TaskRow) -> std::result::Result<Self, Self::Error> {
        Ok(Self {
            id: row.id,
            summary: row.summary,
            action: row.action.parse::<TaskAction>()?,
            question_prompt: row.question_prompt,
            question_url: row.question_url,
        })
    }
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct FetchData {
    task: Task,
    approaches: Vec<Approach>,
}

pub async fn fetch(
    ctx: Extension<ApiContext>,
    Path(task_id): Path<String>,
) -> Result<ApiJson<ApiResponse<FetchData>>> {
    let task: Task = sqlx::query_as::<_, TaskRow>("select * from tasks where id = ?")
        .bind(&task_id)
        .fetch_one(&ctx.db)
        .await?
        .try_into()?;

    let approaches = sqlx::query_as::<_, Approach>("select * from approaches where task_id = ?")
        .bind(&task_id)
        .fetch_all(&ctx.db)
        .await?;

    Ok(ApiJson(ApiResponse::data(FetchData { task, approaches })))
}

pub type ListData = Vec<Task>;

pub async fn list(
    ctx: Extension<ApiContext>,
    search: Option<Query<Search>>,
) -> Result<ApiJson<ApiResponse<ListData>>> {
    let search = search.unwrap_or_default().0;
    info!("searching problems: {:?}", search);
    let data = crate::sqlx::tasks::list(&ctx.db, 20, search).await?;
    Ok(ApiJson(ApiResponse::data(data)))
}

fn ensure_valid_problem_update(
    payload: &AddPayload,
) -> Result<(String, Option<String>, Option<String>)> {
    let AddPayload {
        question_prompt: mut question_text,
        mut question_url,
        summary,
        ..
    } = payload.clone();

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

    Ok((summary.to_string(), question_text, question_url))
}

#[derive(Clone, Deserialize, Serialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct AddPayload {
    pub question_prompt: Option<String>,
    pub question_url: Option<String>,
    pub repo_id: String,
    pub action: TaskAction,
    pub summary: String,
}

#[derive(Clone, Deserialize, Serialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct AddData {
    pub added_task_id: String,
}

pub async fn add(
    ctx: Extension<ApiContext>,
    Path(repo_id): Path<String>,
    ApiJson(payload): ApiJson<AddPayload>,
) -> Result<ApiJson<ApiResponse<AddData>>> {
    info!("adding problem: {:?}", payload);
    let added_task_id = Uuid::new_v4().to_string();
    let (summary, question_prompt, question_url) = ensure_valid_problem_update(&payload)?;

    sqlx::query(
        "insert into tasks
            (id, author_id, repo_id, action, summary, question_prompt, question_url)
            values ($1, $2, $3, $4, $5, $6, $7)",
    )
    .bind(&added_task_id)
    .bind(PLACEHOLDER_USER_ID)
    .bind(&repo_id)
    .bind(payload.action.to_string())
    .bind(&summary)
    .bind(&question_prompt)
    .bind(&question_url)
    .execute(&ctx.db)
    .await?;

    let new_approach_id = Uuid::new_v4().to_string();

    sqlx::query("insert into approaches (id, task_id, unspecified, summary) values (?, ?, ?, ?)")
        .bind(&new_approach_id)
        .bind(&added_task_id)
        .bind(true)
        .bind("Unspecified")
        .execute(&ctx.db)
        .await?;

    Ok(ApiJson(ApiResponse::data(AddData { added_task_id })))
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct UpdatePayload {
    // The action is immutible
    pub question_prompt: Option<String>,
    pub question_url: Option<String>,
    pub summary: String,
    pub task_id: String,
}

pub async fn update(
    ctx: Extension<ApiContext>,
    Path(task_id): Path<String>,
    ApiJson(payload): ApiJson<UpdatePayload>,
) -> Result<ApiOk> {
    info!("updating problem: {:?}", payload);

    fn maybe_none(value: Option<String>) -> Option<String> {
        value.filter(|value| !value.trim().is_empty())
    }

    if task_id != payload.task_id {
        return Err(ApiError::UnprocessableEntity(String::from(
            "task id in request must match the task id in the payload",
        )));
    }

    let question_prompt = maybe_none(payload.question_prompt);
    let question_url = maybe_none(payload.question_url);

    sqlx::query(
        "update tasks
            set summary = $1, question_prompt = $2, question_url = $3
         where id = $4",
    )
    .bind(&payload.summary)
    .bind(&question_prompt)
    .bind(&question_url)
    .bind(&task_id)
    .execute(&ctx.db)
    .await?;

    Ok(ApiJson::ok())
}

pub mod prereqs {
    use super::*;
    use uuid::Uuid;

    #[derive(Debug, Deserialize, Serialize)]
    #[serde(rename_all = "camelCase")]
    pub struct AddPayload {
        pub task_id: String,
        pub approach_id: String,
        pub prereq_task_id: String,
        pub prereq_approach_id: String,
    }

    pub async fn add(
        ctx: Extension<ApiContext>,
        Path(task_id): Path<String>,
        ApiJson(payload): ApiJson<AddPayload>,
    ) -> Result<ApiOk> {
        info!("adding prerequisite task: {payload:?}");

        if task_id != payload.task_id {
            return Err(ApiError::UnprocessableEntity(String::from(
                "task id must match the payload",
            )));
        }

        let new_id: String = Uuid::new_v4().into();

        sqlx::query(
            "insert into approach_prereqs (id, approach_id, prereq_approach_id)
                values (?, ?, ?)
                on conflict do nothing",
        )
        .bind(&new_id)
        .bind(&payload.approach_id)
        .bind(&payload.prereq_approach_id)
        .execute(&ctx.db)
        .await?;

        Ok(ApiJson::ok())
    }

    #[derive(Debug, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct RemovePayload {
        task_id: String,
        approach_id: String,
        prereq_task_id: String,
        prereq_approach_id: String,
    }

    pub async fn remove(
        ctx: Extension<ApiContext>,
        Path(task_id): Path<String>,
        ApiJson(payload): ApiJson<RemovePayload>,
    ) -> Result<ApiOk> {
        info!("adding prerequisite skill: {payload:?}");

        if task_id != payload.task_id {
            return Err(ApiError::UnprocessableEntity(String::from(
                "task id must match the payload",
            )));
        }

        sqlx::query(
            "delete from approach_prereqs
             where approach_id = ? and prereq_skill_id = ? and prereq_approach_id = ?",
        )
        .bind(&payload.approach_id)
        .bind(&payload.prereq_task_id)
        .bind(&payload.prereq_approach_id)
        .execute(&ctx.db)
        .await?;

        Ok(ApiJson::ok())
    }
}
