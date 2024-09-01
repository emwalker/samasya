use crate::types::{ApiOk, ApiResponse, Result, Skill};
use crate::{types::ApiJson, ApiContext};
use axum::extract::Path;
use axum::{extract::Query, Extension};
use serde::{Deserialize, Serialize};
use tracing::info;

#[derive(Deserialize)]
pub struct Filter {
    q: Option<String>,
}

pub type ListData = Vec<Skill>;

pub async fn list(
    ctx: Extension<ApiContext>,
    query: Query<Filter>,
) -> Result<ApiJson<ApiResponse<ListData>>> {
    let filter = query.0;

    let data = if let Some(filter) = filter.q {
        let filter = format!("%{}%", filter);
        sqlx::query_as::<_, Skill>("select * from skills where summary like $1 limit 20")
            .bind(filter)
    } else {
        sqlx::query_as::<_, Skill>("select * from skills limit 20")
    }
    .fetch_all(&ctx.db)
    .await?;

    Ok(ApiJson(ApiResponse::data(data)))
}

#[derive(Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct PrereqProblem {
    prereq_approach_id: Option<String>,
    prereq_approach_name: Option<String>,
    prereq_problem_id: String,
    prereq_problem_summary: String,
    skill_id: String,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct WideSkill {
    skill: Skill,
    prereq_problems: Vec<PrereqProblem>,
}

pub async fn fetch(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
) -> Result<ApiJson<ApiResponse<WideSkill>>> {
    let skill = sqlx::query_as::<_, Skill>("select * from skills where id = ?")
        .bind(&id)
        .fetch_one(&ctx.db)
        .await?;

    let prereq_problems = sqlx::query_as::<_, PrereqProblem>(
        "select pp.*, p.summary prereq_problem_summary, a.name prereq_approach_name
         from prereq_problems pp
         join problems p on pp.prereq_problem_id = p.id
         left join approaches a on pp.prereq_approach_id = a.id
         where pp.skill_id = ?
         order by pp.added_at desc",
    )
    .bind(&id)
    .fetch_all(&ctx.db)
    .await?;

    let skill = WideSkill {
        skill,
        prereq_problems,
    };

    Ok(ApiJson(ApiResponse::data(skill)))
}

#[derive(Deserialize, Serialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct UpdatePayload {
    summary: String,
    description: Option<String>,
}

pub async fn add(
    ctx: Extension<ApiContext>,
    ApiJson(payload): ApiJson<UpdatePayload>,
) -> Result<ApiOk> {
    info!("{:?}", payload);
    let id = uuid::Uuid::new_v4().to_string();

    let description = if let Some(description) = &payload.description {
        if description.is_empty() {
            None
        } else {
            Some(description.trim())
        }
    } else {
        None
    };

    sqlx::query(
        r#"
        insert into skills (id, summary, description) values ($1, $2, $3)
        "#,
    )
    .bind(&id)
    .bind(payload.summary.trim())
    .bind(description)
    .execute(&ctx.db)
    .await?;

    Ok(ApiJson::ok())
}

pub async fn update(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
    ApiJson(payload): ApiJson<UpdatePayload>,
) -> Result<ApiOk> {
    info!("{:?}", payload);

    let description = if let Some(description) = &payload.description {
        if description.is_empty() {
            None
        } else {
            Some(description.trim())
        }
    } else {
        None
    };

    sqlx::query("update skills set summary = $1, description = $2 where id = $3")
        .bind(payload.summary.trim())
        .bind(description)
        .bind(&id)
        .execute(&ctx.db)
        .await?;

    Ok(ApiJson::ok())
}

pub mod prereqs {
    use sqlx::{QueryBuilder, Sqlite};

    use super::*;
    use crate::{
        problems::Search,
        types::{ApiJson, ApiResponse, Problem},
    };

    pub type ListData = Vec<Problem>;

    pub async fn available_problems(
        ctx: Extension<ApiContext>,
        Path(skill_id): Path<String>,
        search: Option<Query<Search>>,
    ) -> Result<ApiJson<ApiResponse<ListData>>> {
        let search = search.unwrap_or_default().0;
        info!(
            "searching for available problems for {skill_id}: {:?}",
            search
        );

        let mut builder: QueryBuilder<Sqlite> = QueryBuilder::new("select p.* from problems p ");
        let mut wheres = vec![];

        for (i, substring) in search.substrings().enumerate() {
            builder.push(format!("join problems p{i} on p.id = p{i}.id "));
            wheres.push(substring);
        }

        builder.push("where ");
        let mut separated = builder.separated(" and ");

        for (i, substring) in wheres.into_iter().enumerate() {
            separated.push(format!("lower(p{i}.summary) like '%'||lower("));
            separated.push_bind_unseparated(substring);
            separated.push_unseparated(")||'%'");
        }

        separated.push(
            "not exists (
                select pp.prereq_problem_id
                from prereq_problems pp
                where pp.prereq_problem_id = p.id
                    and pp.skill_id = ",
        );
        separated.push_bind_unseparated(skill_id);
        separated.push_unseparated(")");

        builder.push("order by p.added_at desc limit ").push_bind(7);
        let problems = builder
            .build_query_as::<Problem>()
            .fetch_all(&ctx.db)
            .await?;

        Ok(ApiJson(ApiResponse::data(problems)))
    }

    #[derive(Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct AddProblemPayload {
        skill_id: String,
        prereq_problem_id: String,
        prereq_approach_id: Option<String>,
    }

    pub async fn add_problem(
        ctx: Extension<ApiContext>,
        ApiJson(AddProblemPayload {
            skill_id,
            prereq_problem_id,
            prereq_approach_id,
        }): ApiJson<AddProblemPayload>,
    ) -> Result<ApiOk> {
        sqlx::query(
            r#"
            insert into prereq_problems (skill_id, prereq_problem_id, prereq_approach_id)
                values ($1, $2, $3)
                on conflict do nothing
            "#,
        )
        .bind(&skill_id)
        .bind(&prereq_problem_id)
        .bind(&prereq_approach_id)
        .execute(&ctx.db)
        .await?;

        Ok(ApiJson::ok())
    }

    #[derive(Debug, Deserialize, Serialize)]
    #[serde(rename_all = "camelCase")]
    pub struct RemoveProblemPayload {
        skill_id: String,
        prereq_problem_id: String,
        prereq_approach_id: Option<String>,
    }

    pub async fn remove_problem(
        ctx: Extension<ApiContext>,
        ApiJson(payload): ApiJson<RemoveProblemPayload>,
    ) -> Result<ApiOk> {
        let result = if let Some(approach_id) = &payload.prereq_approach_id {
            sqlx::query(
                r#"
                delete from prereq_problems
                where skill_id = $1 and prereq_problem_id = $2 and prereq_approach_id = $3
                "#,
            )
            .bind(&payload.skill_id)
            .bind(&payload.prereq_problem_id)
            .bind(approach_id)
        } else {
            sqlx::query(
                r#"
                    delete from prereq_problems
                    where skill_id = $1 and prereq_problem_id = $2 and prereq_approach_id is null
                    "#,
            )
            .bind(&payload.skill_id)
            .bind(&payload.prereq_problem_id)
        }
        .execute(&ctx.db)
        .await?;
        info!("prereq problems removed for {:?}: {:?}", payload, result);

        Ok(ApiJson::ok())
    }
}
