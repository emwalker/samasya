use crate::{
    types::{ApiError, ApiJson, ApiOk, ApiResponse, Approach, Result, Search, Task, TaskAction},
    ApiContext,
};
use axum::{
    extract::{Path, Query},
    Extension,
};
use serde::{Deserialize, Serialize};
use tracing::info;

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
}

impl TryFrom<TaskRow> for Task {
    type Error = ApiError;

    fn try_from(row: TaskRow) -> std::result::Result<Self, Self::Error> {
        Ok(Self {
            id: row.id,
            summary: row.summary,
            action: row.action.parse::<TaskAction>()?,
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
    ApiJson(update): ApiJson<UpdatePayload>,
) -> Result<ApiJson<ApiResponse<String>>> {
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

    Ok(ApiJson::ok())
}

pub async fn update(
    ctx: Extension<ApiContext>,
    Path(problem_id): Path<String>,
    ApiJson(update): ApiJson<UpdatePayload>,
) -> Result<ApiOk> {
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
