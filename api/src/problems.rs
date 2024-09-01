use crate::{
    types::{ApiError, ApiJson, ApiOk, ApiResponse, Approach, Problem, Result},
    ApiContext,
};
use axum::{
    extract::{Path, Query},
    Extension,
};
use serde::{Deserialize, Serialize};
use tracing::info;

#[derive(Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
struct PrereqSkill {
    problem_id: String,
    approach_id: Option<String>,
    prereq_skill_id: String,
    prereq_skill_summary: String,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ProblemData {
    problem: Problem,
    approaches: Vec<Approach>,
    prereq_skills: Vec<PrereqSkill>,
}

pub async fn fetch(
    ctx: Extension<ApiContext>,
    Path(problem_id): Path<String>,
) -> Result<ApiJson<ApiResponse<ProblemData>>> {
    let problem = sqlx::query_as::<_, Problem>("select * from problems where id = ?")
        .bind(&problem_id)
        .fetch_one(&ctx.db)
        .await?;

    let approaches = sqlx::query_as::<_, Approach>("select * from approaches where problem_id = ?")
        .bind(&problem_id)
        .fetch_all(&ctx.db)
        .await?;

    let prereq_skills = sqlx::query_as::<_, PrereqSkill>(
        "select
            ps.problem_id,
            ps.approach_id,
            ps.prereq_skill_id,
            s.summary prereq_skill_summary
         from prereq_skills ps
         join skills s on ps.prereq_skill_id = s.id
         where ps.problem_id = ?",
    )
    .bind(&problem_id)
    .fetch_all(&ctx.db)
    .await?;

    Ok(ApiJson(ApiResponse::data(ProblemData {
        problem,
        approaches,
        prereq_skills,
    })))
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

pub type ListData = Vec<Problem>;

pub async fn list(
    ctx: Extension<ApiContext>,
    search: Option<Query<Search>>,
) -> Result<ApiJson<ApiResponse<ListData>>> {
    let search = search.unwrap_or_default().0;
    info!("searching problems: {:?}", search);
    let data = crate::sqlx::problems::list(&ctx.db, 20, search).await?;
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
    use crate::types::{ApiResponse, Skill};
    use sqlx::{QueryBuilder, Sqlite};

    #[derive(Debug, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct AddSkillPayload {
        problem_id: String,
        approach_id: Option<String>,
        prereq_skill_id: String,
    }

    pub async fn add_skill(
        ctx: Extension<ApiContext>,
        Path(problem_id): Path<String>,
        ApiJson(payload): ApiJson<AddSkillPayload>,
    ) -> Result<ApiOk> {
        info!("adding prerequisite skill: {payload:?}");

        if problem_id != payload.problem_id {
            return Err(ApiError::UnprocessableEntity(String::from(
                "problem id must match the payload",
            )));
        }

        sqlx::query(
            "insert into prereq_skills (problem_id, approach_id, prereq_skill_id)
                values (?, ?, ?)
                on conflict do nothing",
        )
        .bind(&problem_id)
        .bind(&payload.approach_id)
        .bind(&payload.prereq_skill_id)
        .execute(&ctx.db)
        .await?;

        Ok(ApiJson::ok())
    }

    #[derive(Debug, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct RemoveSkillPayload {
        problem_id: String,
        approach_id: Option<String>,
        prereq_skill_id: String,
    }

    pub async fn remove_skill(
        ctx: Extension<ApiContext>,
        Path(problem_id): Path<String>,
        ApiJson(payload): ApiJson<RemoveSkillPayload>,
    ) -> Result<ApiOk> {
        info!("adding prerequisite skill: {payload:?}");

        if problem_id != payload.problem_id {
            return Err(ApiError::UnprocessableEntity(String::from(
                "problem id must match the payload",
            )));
        }

        if let Some(approach_id) = payload.approach_id {
            sqlx::query(
                "delete from prereq_skills
                 where problem_id = ? and approach_id = ? and prereq_skill_id = ?",
            )
            .bind(&problem_id)
            .bind(&approach_id)
            .bind(&payload.prereq_skill_id)
            .execute(&ctx.db)
            .await?;
        } else {
            sqlx::query(
                "delete from prereq_skills
                     where problem_id = ? and approach_id is null and prereq_skill_id = ?",
            )
            .bind(&problem_id)
            .bind(&payload.prereq_skill_id)
            .execute(&ctx.db)
            .await?;
        }

        Ok(ApiJson::ok())
    }

    pub type ListData = Vec<Skill>;

    pub async fn available_skills(
        ctx: Extension<ApiContext>,
        Path(problem_id): Path<String>,
        search: Option<Query<Search>>,
    ) -> Result<ApiJson<ApiResponse<ListData>>> {
        let search = search.unwrap_or_default().0;
        info!(
            "searching for available skills for {problem_id}: {:?}",
            search
        );

        let mut builder: QueryBuilder<Sqlite> = QueryBuilder::new(
            "select distinct s.*
             from prereq_skills ps
             join skills s on ps.prereq_skill_id = s.id ",
        );
        let mut wheres = vec![];

        for (i, substring) in search.substrings().enumerate() {
            builder.push(format!("join skills s{i} on s.id = s{i}.id "));
            wheres.push(substring);
        }

        builder.push("where ");
        let mut separated = builder.separated(" and ");

        for (i, substring) in wheres.into_iter().enumerate() {
            separated.push(format!("lower(s{i}.summary) like '%'||lower("));
            separated.push_bind_unseparated(substring);
            separated.push_unseparated(")||'%'");
        }

        separated.push(
            "not exists (
                select ps.prereq_skill_id
                from prereq_skills ps
                where ps.prereq_skill_id = s.id
                    and ps.problem_id = ",
        );
        separated.push_bind_unseparated(problem_id);
        separated.push_unseparated(")");

        builder
            .push("order by ps.added_at desc limit ")
            .push_bind(7);
        let skills = builder.build_query_as::<Skill>().fetch_all(&ctx.db).await?;

        Ok(ApiJson(ApiResponse::data(skills)))
    }
}
