use axum::{
    extract::Extension,
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use hyper::StatusCode;
use serde::{Deserialize, Serialize};
use serde_json::json;
use sqlx::{sqlite::SqlitePoolOptions, SqlitePool};
use std::sync::Arc;
use thiserror::Error;
use tower_http::cors::CorsLayer;
use tracing::info;

#[derive(Error, Debug)]
pub enum Error {
    #[error("not found")]
    NotFound,
    #[error("failed to connect to database: {0}")]
    Database(String),
}

impl IntoResponse for Error {
    fn into_response(self) -> axum::response::Response {
        let (status, error_message) = match self {
            Self::Database(message) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                format!("Internal server error: {}", message),
            ),
            Self::NotFound => (StatusCode::NOT_FOUND, "Not found".into()),
        };
        (status, Json(json!({ "error": error_message }))).into_response()
    }
}

pub type Result<T, E = Error> = std::result::Result<T, E>;

struct Config {
    db_filename: String,
}

#[derive(Clone)]
struct ApiContext {
    #[allow(unused)]
    config: Arc<Config>,
    db: SqlitePool,
}

#[derive(Serialize, sqlx::FromRow)]
struct Skill {
    id: String,
    description: String,
}

#[derive(Deserialize, Serialize, Debug)]
struct AddSkill {
    description: String,
}

#[derive(Serialize)]
struct SkillsListResponse {
    data: Vec<Skill>,
}

#[derive(Serialize, sqlx::FromRow)]
struct Problem {
    id: String,
    description: String,
}

#[derive(Deserialize, Serialize, Debug)]
struct AddProblem {
    description: String,
}

#[derive(Serialize)]
struct ProblemsListResponse {
    data: Vec<Problem>,
}

async fn root() -> &'static str {
    "Hello, World!"
}

async fn get_skills(ctx: Extension<ApiContext>) -> Result<Json<SkillsListResponse>> {
    let data = sqlx::query_as::<_, Skill>("select * from skills")
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

#[axum_macros::debug_handler]
async fn get_problems(ctx: Extension<ApiContext>) -> Result<Json<ProblemsListResponse>> {
    let data = sqlx::query_as::<_, Problem>("select * from problems")
        .fetch_all(&ctx.db)
        .await
        .map_err(|err| Error::Database(err.to_string()))?;
    Ok(Json(ProblemsListResponse { data }))
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

    Ok(Json(json!({})))
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    let db_filename = "./database.db";

    let config = Config {
        db_filename: db_filename.into(),
    };

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
        .layer(Extension(ctx))
        .layer(CorsLayer::permissive());

    axum::Server::bind(&"0.0.0.0:8000".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();

    Ok(())
}
