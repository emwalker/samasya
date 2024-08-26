use axum::{
    extract::{Extension, Path},
    routing::{get, post, put},
    Json, Router,
};
use samasya::{
    queues, skills,
    sqlx::{approaches, problems},
    types::{ApiError, Approach, Problem, Result, WideApproach, WideProblem},
    ApiContext, Config,
};
use serde::{Deserialize, Serialize};
use serde_json::json;
use sqlx::sqlite::SqlitePoolOptions;
use std::sync::Arc;
use tower_http::cors::CorsLayer;
use tracing::info;

#[derive(Deserialize, Serialize, Debug)]
#[serde(rename_all = "camelCase")]
struct ProblemUpdate {
    question_text: Option<String>,
    question_url: Option<String>,
    summary: String,
}

#[derive(Deserialize, Serialize, Debug)]
#[serde(rename_all = "camelCase")]
struct ApproachUpdate {
    name: String,
    problem_id: String,
    prereq_approach_ids: Vec<String>,
    prereq_skill_ids: Vec<String>,
}

async fn root() -> &'static str {
    "Hello, World!"
}

#[derive(Serialize)]
struct ProblemResponse {
    data: WideProblem,
}

async fn get_problem(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
) -> Result<Json<ProblemResponse>> {
    let data = problems::fetch_wide(&ctx.db, &id).await?;
    Ok(Json(ProblemResponse { data }))
}

#[derive(Serialize)]
struct ProblemsListResponse {
    data: Vec<Problem>,
}

async fn get_problems(ctx: Extension<ApiContext>) -> Result<Json<ProblemsListResponse>> {
    let data = problems::fetch_all(&ctx.db, 20).await?;
    Ok(Json(ProblemsListResponse { data }))
}

fn ensure_valid_problem_update(
    update: ProblemUpdate,
) -> Result<(String, Option<String>, Option<String>)> {
    let ProblemUpdate {
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

async fn post_problem(
    ctx: Extension<ApiContext>,
    Json(update): Json<ProblemUpdate>,
) -> Result<Json<serde_json::Value>> {
    info!("adding problem: {:?}", update);
    let id = uuid::Uuid::new_v4().to_string();

    let (summary, question_text, question_url) = ensure_valid_problem_update(update)?;

    sqlx::query(
        "insert into problems (id, summary, question_text, question_url)
         values ($1, $2, $3, $4)",
    )
    .bind(&id)
    .bind(&summary)
    .bind(&question_text)
    .bind(&question_url)
    .execute(&ctx.db)
    .await
    .map_err(|err| ApiError::Database(err.to_string()))?;

    Ok(Json(json!({})))
}

async fn put_problem(
    ctx: Extension<ApiContext>,
    Path(problem_id): Path<String>,
    Json(update): Json<ProblemUpdate>,
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
    .await
    .map_err(|err| ApiError::Database(err.to_string()))?;

    Ok(Json(json!({})))
}

async fn post_approach(
    ctx: Extension<ApiContext>,
    Json(update): Json<ApproachUpdate>,
) -> Result<Json<serde_json::Value>> {
    info!("adding approach: {:?}", update);
    let id = uuid::Uuid::new_v4().to_string();

    sqlx::query("insert into approaches (id, problem_id, name) values ($1, $2, $3)")
        .bind(&id)
        .bind(&update.problem_id)
        .bind(&update.name)
        .execute(&ctx.db)
        .await
        .map_err(|err| ApiError::Database(err.to_string()))?;

    for prereq_id in update.prereq_skill_ids {
        sqlx::query("insert into prereq_skills (approach_id, prereq_skill_id) values ($1, $2)")
            .bind(&id)
            .bind(&prereq_id)
            .execute(&ctx.db)
            .await
            .map_err(|err| ApiError::Database(err.to_string()))?;
    }

    for prereq_id in update.prereq_approach_ids {
        sqlx::query(
            "insert into prereq_problems (problem_id, prereq_approach_id)
             values ($1, $2)",
        )
        .bind(&id)
        .bind(&prereq_id)
        .execute(&ctx.db)
        .await
        .map_err(|err| ApiError::Database(err.to_string()))?;
    }

    Ok(Json(json!({})))
}

async fn put_approach(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
    Json(update): Json<ApproachUpdate>,
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
struct ApproachResponse {
    data: WideApproach,
}

async fn get_approach(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
) -> Result<Json<ApproachResponse>> {
    let data = approaches::fetch_wide(&ctx.db, &id).await?;
    Ok(Json(ApproachResponse { data }))
}

#[derive(Serialize)]
struct ApproachListResponse {
    data: Vec<Approach>,
}

async fn get_approaches(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
) -> Result<Json<ApproachListResponse>> {
    let problem_id = id;
    let data = approaches::fetch_all(&ctx.db, &problem_id, 20).await?;
    Ok(Json(ApproachListResponse { data }))
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();
    let config = Config::load()?;
    info!("using {}", config.db_filename);

    let db = SqlitePoolOptions::new()
        .max_connections(1)
        .connect(&format!("sqlite://{}?mode=rwc", config.db_filename))
        .await
        .map_err(|err| ApiError::Database(err.to_string()))?;

    let ctx = ApiContext {
        config: Arc::new(config),
        db,
    };

    sqlx::migrate!("./migrations")
        .run(&ctx.db)
        .await
        .map_err(|err| ApiError::Database(err.to_string()))?;

    let app = Router::new()
        .route("/", get(root))
        .route("/api/v1/approaches", post(post_approach))
        .route("/api/v1/approaches/:id", get(get_approach))
        .route("/api/v1/approaches/:id", put(put_approach))
        .route("/api/v1/problems", get(get_problems))
        .route("/api/v1/problems", post(post_problem))
        .route("/api/v1/problems/:id", get(get_problem))
        .route("/api/v1/problems/:id", put(put_problem))
        .route("/api/v1/problems/:id/approaches", get(get_approaches))
        .route("/api/v1/queues/:id", get(queues::get))
        .route("/api/v1/skills", get(skills::list))
        .route("/api/v1/skills", post(skills::add))
        .route("/api/v1/skills/:id", get(skills::get))
        .route("/api/v1/skills/:id", put(skills::update))
        .route("/api/v1/users/:id/queues", get(queues::list))
        .route("/api/v1/users/:id/queues", post(queues::add))
        .route(
            "/api/v1/skills/:id/prereqs/add-problem",
            post(skills::prereqs::add_problem),
        )
        .route(
            "/api/v1/skills/:id/prereqs/remove-problem",
            post(skills::prereqs::remove_problem),
        )
        .layer(Extension(ctx))
        .layer(CorsLayer::permissive());

    axum::Server::bind(&"0.0.0.0:8000".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();

    Ok(())
}
