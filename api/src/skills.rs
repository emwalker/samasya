use crate::types::{ApiErrorResponse, Result, Skill};
use crate::ApiContext;
use axum::extract::Path;
use axum::{extract::Query, Extension, Json};
use serde::{Deserialize, Serialize};
use serde_json::json;
use tracing::info;

#[derive(Deserialize)]
pub struct Filter {
    q: Option<String>,
}

#[derive(Serialize)]
pub struct ListResponse {
    data: Vec<Skill>,
}

pub async fn list(ctx: Extension<ApiContext>, query: Query<Filter>) -> Result<Json<ListResponse>> {
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

    Ok(Json(ListResponse { data }))
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

#[derive(Serialize)]
pub struct FetchResponse {
    data: Option<WideSkill>,
    errors: Vec<ApiErrorResponse>,
}

pub async fn fetch(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
) -> Result<Json<FetchResponse>> {
    let skill = sqlx::query_as::<_, Skill>("select * from skills where id = ?")
        .bind(&id)
        .fetch_one(&ctx.db)
        .await?;

    let prereq_problems = sqlx::query_as::<_, PrereqProblem>(
        r#"
        select pp.*, p.summary prereq_problem_summary, a.name prereq_approach_name
        from prereq_problems pp
        join problems p on pp.prereq_problem_id = p.id
        left join approaches a on pp.prereq_approach_id = a.id
        where pp.skill_id = ?
        order by pp.added_at desc
        "#,
    )
    .bind(&id)
    .fetch_all(&ctx.db)
    .await?;

    let skill = WideSkill {
        skill,
        prereq_problems,
    };

    Ok(Json(FetchResponse {
        data: Some(skill),
        errors: vec![],
    }))
}

#[derive(Deserialize, Serialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct UpdatePayload {
    summary: String,
    description: Option<String>,
}

pub async fn add(
    ctx: Extension<ApiContext>,
    Json(payload): Json<UpdatePayload>,
) -> Result<Json<serde_json::Value>> {
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

    Ok(Json(json!({})))
}

pub async fn update(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
    Json(payload): Json<UpdatePayload>,
) -> Result<Json<serde_json::Value>> {
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

    Ok(Json(json!({})))
}

pub mod prereqs {
    use super::*;

    #[derive(Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct AddProblemPayload {
        skill_id: String,
        prereq_problem_id: String,
        prereq_approach_id: Option<String>,
    }

    #[derive(Serialize)]
    pub struct AddProblemResponse {
        data: Option<String>,
        errors: Vec<ApiErrorResponse>,
    }

    impl AddProblemResponse {
        fn ok() -> Self {
            Self {
                data: None,
                errors: vec![],
            }
        }
    }

    pub async fn add_problem(
        ctx: Extension<ApiContext>,
        Json(AddProblemPayload {
            skill_id,
            prereq_problem_id,
            prereq_approach_id,
        }): Json<AddProblemPayload>,
    ) -> Result<Json<AddProblemResponse>> {
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

        Ok(Json(AddProblemResponse::ok()))
    }

    #[derive(Debug, Deserialize, Serialize)]
    #[serde(rename_all = "camelCase")]
    pub struct RemoveProblemPayload {
        skill_id: String,
        prereq_problem_id: String,
        prereq_approach_id: Option<String>,
    }

    #[derive(Serialize)]
    pub struct RemoveProblemResponse {
        data: Option<RemoveProblemPayload>,
        errors: Vec<ApiErrorResponse>,
    }

    pub async fn remove_problem(
        ctx: Extension<ApiContext>,
        Json(payload): Json<RemoveProblemPayload>,
    ) -> Result<Json<RemoveProblemResponse>> {
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

        Ok(Json(RemoveProblemResponse {
            data: Some(payload),
            errors: vec![],
        }))
    }
}
