use axum::{
    extract::{Extension, Path, Query},
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use hyper::StatusCode;
use serde::{Deserialize, Serialize};
use serde_json::json;
use sqlx::{sqlite::SqlitePoolOptions, SqlitePool};
use std::env;
use std::sync::Arc;
use thiserror::Error;
use tower_http::cors::CorsLayer;
use tracing::info;

#[derive(Error, Debug)]
pub enum Error {
    #[error("failed to load config")]
    Config(String),
    #[error("failed to connect to database: {0}")]
    Database(String),
    #[error("not found")]
    NotFound,
}

impl IntoResponse for Error {
    fn into_response(self) -> axum::response::Response {
        let (status, error_message) = match self {
            Self::Database(message) | Self::Config(message) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                format!("Internal server error: {}", message),
            ),
            Self::NotFound => (StatusCode::NOT_FOUND, "Not found".into()),
        };
        (status, Json(json!({ "error": error_message }))).into_response()
    }
}

pub type Result<T, E = Error> = std::result::Result<T, E>;

#[derive(Deserialize, Serialize)]
struct Config {
    db_filename: String,
}

impl Config {
    fn load() -> Result<Self> {
        let profile = env::var("ENV").unwrap_or("development".into());
        dotenv::from_filename(format!(".env.{}.local", profile)).ok();
        dotenv::dotenv().ok();
        envy::from_env::<Self>().map_err(|err| Error::Config(err.to_string()))
    }
}

#[derive(Clone)]
struct ApiContext {
    #[allow(unused)]
    config: Arc<Config>,
    db: SqlitePool,
}

#[derive(Clone, Serialize, sqlx::FromRow)]
struct Skill {
    id: String,
    description: String,
}

#[derive(Deserialize, Serialize, Debug)]
#[serde(rename_all = "camelCase")]
struct AddSkill {
    description: String,
}

#[derive(Serialize)]
struct SkillsListResponse {
    data: Vec<Skill>,
}

#[derive(sqlx::FromRow)]
struct ProblemRow {
    id: String,
    description: String,
}

#[derive(Clone, Serialize)]
struct Problem {
    id: String,
    description: String,
    skills: Vec<Skill>,
}

#[derive(Deserialize, Serialize, Debug)]
#[serde(rename_all = "camelCase")]
struct AddProblem {
    description: String,
    skill_ids: Vec<String>,
}

#[derive(Serialize)]
struct ProblemsListResponse {
    data: Vec<Problem>,
}

async fn root() -> &'static str {
    "Hello, World!"
}

#[derive(Deserialize)]
struct Filter {
    q: Option<String>,
}

async fn get_skills(
    ctx: Extension<ApiContext>,
    query: Query<Filter>,
) -> Result<Json<SkillsListResponse>> {
    let filter = query.0;

    let data = if let Some(filter) = filter.q {
        let filter = format!("%{}%", filter);
        sqlx::query_as::<_, Skill>("select * from skills where description like $1").bind(filter)
    } else {
        sqlx::query_as::<_, Skill>("select * from skills")
    }
    .fetch_all(&ctx.db)
    .await
    .map_err(|err| Error::Database(err.to_string()))?;

    Ok(Json(SkillsListResponse { data }))
}

async fn post_skill(
    ctx: Extension<ApiContext>,
    Json(payload): Json<AddSkill>,
) -> Result<Json<serde_json::Value>> {
    info!("payload: {:?}", payload);
    let id = uuid::Uuid::new_v4().to_string();

    sqlx::query("insert into skills (id, description) values ($1, $2)")
        .bind(&id)
        .bind(&payload.description)
        .execute(&ctx.db)
        .await
        .map_err(|err| Error::Database(err.to_string()))?;

    Ok(Json(json!({})))
}

async fn add_skills(db: &SqlitePool, rows: Vec<ProblemRow>) -> Result<Vec<Problem>> {
    let mut problems: Vec<Problem> = vec![];

    for row in rows {
        let skills = sqlx::query_as::<_, Skill>(
            "select s.*
         from skills s join problems_skills ps on s.id = ps.skill_id
         where ps.problem_id = $1",
        )
        .bind(&row.id)
        .fetch_all(db)
        .await
        .map_err(|err| Error::Database(err.to_string()))?;

        problems.push(Problem {
            id: row.id,
            description: row.description,
            skills,
        })
    }

    Ok(problems)
}

async fn fetch_all(db: &SqlitePool, limit: i32) -> Result<Vec<Problem>> {
    let rows = sqlx::query_as::<_, ProblemRow>("select * from problems limit ?")
        .bind(limit)
        .fetch_all(db)
        .await
        .map_err(|err| Error::Database(err.to_string()))?;
    add_skills(db, rows).await
}

async fn fetch_one(db: &SqlitePool, id: &str) -> Result<Problem> {
    let rows = sqlx::query_as::<_, ProblemRow>("select * from problems where id = ? limit 1")
        .bind(id)
        .fetch_all(db)
        .await
        .map_err(|err| Error::Database(err.to_string()))?;

    let mut problems = add_skills(db, rows).await?;
    if problems.len() == 1 {
        let problem = problems.pop().unwrap();
        return Ok(problem);
    }

    Err(Error::NotFound)
}

#[axum_macros::debug_handler]
async fn get_problems(ctx: Extension<ApiContext>) -> Result<Json<ProblemsListResponse>> {
    let data = fetch_all(&ctx.db, 20).await?;
    Ok(Json(ProblemsListResponse { data }))
}

#[derive(Serialize)]
struct ProblemResponse {
    data: Problem,
}

async fn get_problem(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
) -> Result<Json<ProblemResponse>> {
    let data = fetch_one(&ctx.db, &id).await?;
    Ok(Json(ProblemResponse { data }))
}

#[axum_macros::debug_handler]
async fn post_problem(
    ctx: Extension<ApiContext>,
    Json(payload): Json<AddProblem>,
) -> Result<Json<serde_json::Value>> {
    info!("payload: {:?}", payload);
    let id = uuid::Uuid::new_v4().to_string();

    sqlx::query("insert into problems (id, description) values ($1, $2)")
        .bind(&id)
        .bind(&payload.description)
        .execute(&ctx.db)
        .await
        .map_err(|err| Error::Database(err.to_string()))?;

    for skill_id in payload.skill_ids {
        sqlx::query("insert into problems_skills (problem_id, skill_id) values ($1, $2)")
            .bind(&id)
            .bind(&skill_id)
            .execute(&ctx.db)
            .await
            .map_err(|err| Error::Database(err.to_string()))?;
    }

    Ok(Json(json!({})))
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
        .map_err(|err| Error::Database(err.to_string()))?;

    let ctx = ApiContext {
        config: Arc::new(config),
        db,
    };

    sqlx::migrate!("./migrations")
        .run(&ctx.db)
        .await
        .map_err(|err| Error::Database(err.to_string()))?;

    let app = Router::new()
        .route("/", get(root))
        .route("/api/v1/skills", get(get_skills))
        .route("/api/v1/skills", post(post_skill))
        .route("/api/v1/problems", get(get_problems))
        .route("/api/v1/problems", post(post_problem))
        .route("/api/v1/problems/:id", get(get_problem))
        .layer(Extension(ctx))
        .layer(CorsLayer::permissive());

    axum::Server::bind(&"0.0.0.0:8000".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();

    Ok(())
}
