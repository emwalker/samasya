use axum::{
    extract::Extension,
    routing::{get, post, put},
    Router,
};
use samasya::{approaches, problems, queues, skills, types::Result, ApiContext, ApiJson, Config};
use serde::Serialize;
use sqlx::sqlite::SqlitePoolOptions;
use std::sync::Arc;
use tower_http::cors::CorsLayer;
use tracing::info;

#[derive(Serialize)]
struct RootResponse {
    status: String,
    version: String,
    message: String,
}

async fn root() -> ApiJson<RootResponse> {
    ApiJson(RootResponse {
        status: "up".into(),
        version: "v0.0.1".into(),
        message: "Welcome to Samasya".into(),
    })
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();
    let config = Config::load()?;
    info!("using {}", config.db_filename);

    let db = SqlitePoolOptions::new()
        .max_connections(1)
        .connect(&format!("sqlite://{}?mode=rwc", config.db_filename))
        .await?;

    let ctx = ApiContext {
        config: Arc::new(config),
        db,
    };

    sqlx::migrate!("./migrations").run(&ctx.db).await?;

    let app = Router::new()
        .route("/", get(root))
        .route("/api/v1/approaches", post(approaches::add))
        .route("/api/v1/approaches/:id", get(approaches::fetch))
        .route("/api/v1/approaches/:id", put(approaches::update))
        .route("/api/v1/problems", get(problems::list))
        .route("/api/v1/problems", post(problems::add))
        .route("/api/v1/problems/:id", get(problems::fetch))
        .route("/api/v1/problems/:id", put(problems::update))
        .route("/api/v1/problems/:id/approaches", get(approaches::list))
        .route("/api/v1/queues/:id", get(queues::fetch))
        .route("/api/v1/skills", get(skills::list))
        .route("/api/v1/skills", post(skills::add))
        .route("/api/v1/skills/:id", get(skills::fetch))
        .route("/api/v1/skills/:id", put(skills::update))
        .route(
            "/api/v1/skills/:id/prereqs/available-problems",
            get(skills::prereqs::available_problems),
        )
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
