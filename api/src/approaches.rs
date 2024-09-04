use crate::{
    types::{ApiJson, ApiOk, ApiResponse, Result, Task},
    ApiContext,
};
use axum::{extract::Path, Extension};
use serde::{Deserialize, Serialize};
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
    ApiJson(update): ApiJson<UpdatePayload>,
) -> Result<ApiOk> {
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

    Ok(ApiJson::ok())
}

pub async fn update(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
    ApiJson(update): ApiJson<UpdatePayload>,
) -> Result<ApiOk> {
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

    Ok(ApiJson::ok())
}

#[derive(Debug, Deserialize, sqlx::FromRow, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ApproachType {
    pub id: String,
    pub summary: String,
    pub task_id: String,
}

#[derive(Debug, Deserialize, Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct PrereqType {
    task_id: String,
    task_summary: String,
    task_action: String,
    approach_id: String,
    approach_summary: String,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct FetchData {
    pub task: Task,
    pub approach: ApproachType,
    pub prereqs: Vec<PrereqType>,
}

pub async fn fetch(
    ctx: Extension<ApiContext>,
    Path(approach_id): Path<String>,
) -> Result<ApiJson<ApiResponse<FetchData>>> {
    let approach = sqlx::query_as::<_, ApproachType>("select * from approaches where id = ?")
        .bind(&approach_id)
        .fetch_one(&ctx.db)
        .await?;

    let task = sqlx::query_as::<_, Task>("select * from tasks where id = ?")
        .bind(&approach.task_id)
        .fetch_one(&ctx.db)
        .await?;

    let prereqs = sqlx::query_as::<_, PrereqType>(
        "select
            a.task_id,
            t.summary task_summary,
            t.action task_action, a.summary approach_summary,
            a.id approach_id,
            a.summary approach_summary
         from approach_prereqs ap
         join approaches a on ap.prereq_approach_id = a.id
         join tasks t on a.task_id = t.id
         where ap.approach_id = ?
         order by ap.added_at desc",
    )
    .bind(&approach_id)
    .fetch_all(&ctx.db)
    .await?;

    Ok(ApiJson(ApiResponse::data(FetchData {
        task,
        approach,
        prereqs,
    })))
}

pub mod prereqs {
    use super::*;
    use crate::{tasks::Search, types::Task, ApiContext};
    use axum::{
        extract::{Path, Query},
        Extension,
    };
    use sqlx::{QueryBuilder, Sqlite};

    pub type ListData = Vec<Task>;

    pub async fn available(
        ctx: Extension<ApiContext>,
        Path(approach_id): Path<String>,
        search: Option<Query<Search>>,
    ) -> Result<ApiJson<ApiResponse<ListData>>> {
        let search = search.unwrap_or_default().0;
        info!(
            "searching for available prereq tasks for {approach_id}: {:?}",
            search
        );

        let mut builder: QueryBuilder<Sqlite> = QueryBuilder::new(
            "select distinct t.*
             from tasks t ",
        );
        let mut wheres = vec![];

        for (i, substring) in search.substrings().enumerate() {
            builder.push(format!("join tasks t{i} on t.id = t{i}.id "));
            wheres.push(substring);
        }

        builder.push("where ");
        let mut separated = builder.separated(" and ");

        for (i, substring) in wheres.into_iter().enumerate() {
            separated.push(format!("lower(t{i}.summary) like '%'||lower("));
            separated.push_bind_unseparated(substring);
            separated.push_unseparated(")||'%'");
        }

        separated.push(
            "not exists (
                select a.task_id
                from approach_prereqs ap
                join approaches a on ap.prereq_approach_id = a.id
                where t.id = a.task_id and ap.approach_id = ",
        );
        separated.push_bind_unseparated(approach_id);
        separated.push_unseparated(")");

        builder.push("order by t.summary limit ").push_bind(7);
        let skills = builder.build_query_as::<Task>().fetch_all(&ctx.db).await?;

        Ok(ApiJson(ApiResponse::data(skills)))
    }
}
