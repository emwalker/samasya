use axum::{
    extract::{Extension, Path, Query},
    response::{IntoResponse, Response},
    routing::{get, post, put},
    Json, Router,
};
use axum_macros::FromRequest;
use samasya::{
    sqlx::{approaches, problems, queues},
    types::{
        ApiError, ApiErrorResponse, Approach, Problem, Queue, QueueStrategy, Result, Skill,
        WideApproach, WideProblem, WideQueue,
    },
};
use serde::{Deserialize, Serialize};
use serde_json::json;
use sqlx::{sqlite::SqlitePoolOptions, SqlitePool};
use std::env;
use std::sync::Arc;
use tower_http::cors::CorsLayer;
use tracing::info;

#[derive(Deserialize, Serialize)]
struct Config {
    db_filename: String,
}

impl Config {
    fn load() -> Result<Self> {
        let profile = env::var("ENV").unwrap_or("development".into());
        dotenv::from_filename(format!(".env.{}.local", profile)).ok();
        dotenv::dotenv().ok();
        envy::from_env::<Self>().map_err(|err| ApiError::Config(err.to_string()))
    }
}

#[derive(Clone)]
struct ApiContext {
    #[allow(unused)]
    config: Arc<Config>,
    db: SqlitePool,
}

#[derive(FromRequest)]
#[from_request(via(axum::Json), rejection(ApiError))]
struct ApiJson<T>(T);

impl<T> IntoResponse for ApiJson<T>
where
    axum::Json<T>: IntoResponse,
{
    fn into_response(self) -> Response {
        axum::Json(self.0).into_response()
    }
}

#[derive(Deserialize, Serialize, Debug)]
#[serde(rename_all = "camelCase")]
struct SkillUpdate {
    description: String,
}

#[derive(Serialize)]
struct SkillsListResponse {
    data: Vec<Skill>,
}

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
        sqlx::query_as::<_, Skill>("select * from skills where summary like $1 limit 20")
            .bind(filter)
    } else {
        sqlx::query_as::<_, Skill>("select * from skills limit 20")
    }
    .fetch_all(&ctx.db)
    .await
    .map_err(|err| ApiError::Database(err.to_string()))?;

    Ok(Json(SkillsListResponse { data }))
}

async fn post_skill(
    ctx: Extension<ApiContext>,
    Json(payload): Json<SkillUpdate>,
) -> Result<Json<serde_json::Value>> {
    info!("payload: {:?}", payload);
    let id = uuid::Uuid::new_v4().to_string();

    sqlx::query("insert into skills (id, summary) values ($1, $2)")
        .bind(&id)
        .bind(&payload.description)
        .execute(&ctx.db)
        .await
        .map_err(|err| ApiError::Database(err.to_string()))?;

    Ok(Json(json!({})))
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
        .await
        .map_err(|err| ApiError::Database(err.to_string()))?;

    sqlx::query("delete from prereq_skills where approach_id = $1")
        .bind(&id)
        .execute(&ctx.db)
        .await
        .map_err(|err| ApiError::Database(err.to_string()))?;

    for skill_id in update.prereq_skill_ids {
        sqlx::query("insert into prereq_skills (approach_id, prereq_skill_id) values ($1, $2)")
            .bind(&id)
            .bind(&skill_id)
            .execute(&ctx.db)
            .await
            .map_err(|err| ApiError::Database(err.to_string()))?;
    }

    sqlx::query("delete from prereq_approaches where approach_id = $1")
        .bind(&id)
        .execute(&ctx.db)
        .await
        .map_err(|err| ApiError::Database(err.to_string()))?;

    for prereq_id in update.prereq_approach_ids {
        sqlx::query(
            "insert into prereq_approaches (approach_id, prereq_approach_id)
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

#[derive(Serialize)]
struct QueuesListResponse {
    data: Vec<Queue>,
}

async fn get_queues(
    ctx: Extension<ApiContext>,
    Path(user_id): Path<String>,
) -> Result<Json<QueuesListResponse>> {
    let data = queues::fetch_all(&ctx.db, &user_id, 20).await?;
    Ok(Json(QueuesListResponse { data }))
}

#[derive(Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
struct QueueUpdate {
    strategy: QueueStrategy,
    summary: String,
    target_problem_id: String,
}

#[derive(Serialize)]
struct UpdateQueueResponse {
    data: Option<String>,
    errors: Vec<ApiErrorResponse>,
}

impl UpdateQueueResponse {
    fn ok() -> Self {
        Self {
            data: None,
            errors: vec![],
        }
    }
}

async fn post_queue(
    ctx: Extension<ApiContext>,
    Path(user_id): Path<String>,
    ApiJson(update): ApiJson<QueueUpdate>,
) -> Result<Json<UpdateQueueResponse>> {
    info!("user {}: adding queue: {:?}", user_id, update);
    let id = uuid::Uuid::new_v4().to_string();
    let created_at = chrono::Utc::now();

    sqlx::query(
        "insert into queues (
            id, summary, strategy, target_problem_id, user_id, created_at, updated_at
         )
         values ($1, $2, $3, $4, $5, $6, $7)",
    )
    .bind(&id)
    .bind(&update.summary)
    .bind(update.strategy as i32)
    .bind(&update.target_problem_id)
    .bind(&user_id)
    .bind(created_at)
    .bind(created_at)
    .execute(&ctx.db)
    .await
    .map_err(|err| ApiError::Database(err.to_string()))?;

    Ok(Json(UpdateQueueResponse::ok()))
}

#[derive(Serialize)]
struct QueueResponse {
    data: WideQueue,
}

async fn get_queue(
    ctx: Extension<ApiContext>,
    Path(id): Path<String>,
) -> Result<Json<QueueResponse>> {
    let data = queues::fetch_wide(&ctx.db, &id).await?;
    Ok(Json(QueueResponse { data }))
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
        .route("/api/v1/queues/:id", get(get_queue))
        .route("/api/v1/skills", get(get_skills))
        .route("/api/v1/skills", post(post_skill))
        .route("/api/v1/users/:id/queues", get(get_queues))
        .route("/api/v1/users/:id/queues", post(post_queue))
        .layer(Extension(ctx))
        .layer(CorsLayer::permissive());

    axum::Server::bind(&"0.0.0.0:8000".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();

    Ok(())
}
