use crate::{
    approaches, queues, tasks,
    types::{ApiErrorData, ApiErrorLevel, ApiJson, ApiResponse, Result},
    ApiContext, Config,
};
use axum::{
    response::IntoResponse,
    routing::{get, post, put},
    Extension, Router,
};
use hyper::StatusCode;
use serde::{Deserialize, Serialize};
use sqlx::SqlitePool;
use std::sync::Arc;
use tower_http::cors::CorsLayer;
use tracing::info;

#[derive(Deserialize, Serialize)]
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

async fn handle_404() -> impl IntoResponse {
    (
        StatusCode::NOT_FOUND,
        ApiJson(ApiResponse::<String> {
            data: None,
            errors: vec![ApiErrorData {
                level: ApiErrorLevel::Warn,
                message: "No such endpoint".into(),
            }],
        }),
    )
}

pub async fn router(config: Config, db: SqlitePool) -> Result<Router> {
    info!("using {}", config.db_filename);

    let ctx = ApiContext {
        config: Arc::new(config),
        db,
    };

    sqlx::migrate!("./migrations").run(&ctx.db).await?;

    let router = Router::new()
        .route("/", get(root))
        .route("/api/v1/approaches", post(approaches::add))
        .route("/api/v1/approaches/:id", get(approaches::fetch))
        .route("/api/v1/approaches/:id", put(approaches::update))
        .route("/api/v1/queues/:id", get(queues::fetch))
        .route("/api/v1/queues/:id/next-task", get(queues::next_task))
        .route("/api/v1/queues/:id/add-outcome", post(queues::add_outcome))
        .route("/api/v1/tasks", get(tasks::list))
        .route("/api/v1/tasks", post(tasks::add))
        .route("/api/v1/tasks/:id", get(tasks::fetch))
        .route("/api/v1/tasks/:id", put(tasks::update))
        .route(
            "/api/v1/tasks/:id/prereqs/add-approach",
            post(tasks::prereqs::add_approach),
        )
        .route(
            "/api/v1/tasks/:id/prereqs/remove-approach",
            post(tasks::prereqs::remove_approach),
        )
        .route(
            "/api/v1/tasks/:id/prereqs/available-approaches",
            get(tasks::prereqs::available_approaches),
        )
        .route("/api/v1/users/:id/queues", get(queues::list))
        .route("/api/v1/users/:id/queues", post(queues::add))
        .fallback(handle_404)
        .layer(Extension(ctx))
        .layer(CorsLayer::permissive());

    Ok(router)
}

#[cfg(test)]
mod tests {
    use crate::{
        types::{Cadence, QueueStrategy},
        PLACHOLDER_USER_ID,
    };

    use super::*;
    use axum::{
        body::{Body, HttpBody},
        http::{Request, StatusCode},
    };
    use sqlx::SqlitePool;
    use tempfile::tempdir;
    use tower::ServiceExt;

    trait Bytes {
        async fn to_bytes(self) -> Vec<u8>;
    }

    impl<T> Bytes for axum::response::Response<T>
    where
        T: HttpBody,
        <T as HttpBody>::Error: std::fmt::Debug,
    {
        async fn to_bytes(self) -> Vec<u8> {
            self.into_body()
                .collect()
                .await
                .unwrap()
                .to_bytes()
                .into_iter()
                .collect()
        }
    }

    async fn setup(db: SqlitePool) -> Router {
        let path = tempdir()
            .unwrap()
            .path()
            .join("test.db")
            .into_os_string()
            .into_string()
            .unwrap();

        router(Config::with_database(path), db).await.unwrap()
    }

    #[sqlx::test]
    async fn root(pool: SqlitePool) {
        let router = setup(pool).await;

        let response = router
            .oneshot(Request::builder().uri("/").body(Body::empty()).unwrap())
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::OK);

        let body = response.to_bytes().await;
        let response: RootResponse = serde_json::from_slice(&body).unwrap();
        assert_eq!(response.message, "Welcome to Samasya");
        assert_eq!(response.status, "up");
        assert_eq!(response.version, "v0.0.1");
    }

    #[sqlx::test]
    async fn unknown_endpoint(pool: SqlitePool) {
        let router = setup(pool).await;

        let response = router
            .oneshot(
                Request::builder()
                    .uri("/learning/queues")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::NOT_FOUND);

        let body = response.to_bytes().await;
        let response: ApiResponse<String> = serde_json::from_slice(&body).unwrap();
        assert!(response.data.is_none());
        assert_eq!(response.errors.first().unwrap().message, "No such endpoint");
    }

    #[sqlx::test(fixtures("seeds"))]
    async fn list_queues(pool: SqlitePool) {
        let router = setup(pool).await;
        let user_id = PLACHOLDER_USER_ID;

        let response = router
            .oneshot(
                Request::builder()
                    .uri(format!("/api/v1/users/{user_id}/queues"))
                    .method("GET")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::OK);

        let body = response.to_bytes().await;
        let response: ApiResponse<queues::ListData> = serde_json::from_slice(&body).unwrap();
        assert!(!response.data.unwrap().is_empty());
    }

    #[sqlx::test(fixtures("seeds"))]
    async fn add_queue(pool: SqlitePool) {
        let router = setup(pool).await;
        let user_id = PLACHOLDER_USER_ID;

        let payload = queues::AddPayload {
            strategy: QueueStrategy::SpacedRepetitionV1,
            summary: String::from("Test problems"),
            target_approach_id: String::from("e1994385-5e8f-4651-a13b-429bad75bc54"),
            cadence: Cadence::Hours,
        };
        let payload = serde_json::to_string(&payload).unwrap();

        let response = router
            .oneshot(
                Request::builder()
                    .uri(format!("/api/v1/users/{user_id}/queues"))
                    .method("POST")
                    .header("Content-Type", "application/json")
                    .body(Body::from(payload))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::CREATED);
        let body = response.to_bytes().await;
        let response: ApiResponse<queues::AddData> = serde_json::from_slice(&body).unwrap();
        assert!(!response.data.unwrap().added_queue_id.is_empty());
    }

    #[sqlx::test(fixtures("seeds"))]
    async fn fetch_queue(pool: SqlitePool) {
        let router = setup(pool).await;
        let queue_id = "2df309a7-8ece-4a14-a5f5-49699d2cba54";

        let response = router
            .oneshot(
                Request::builder()
                    .uri(format!("/api/v1/queues/{queue_id}"))
                    .method("GET")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);
        let body = response.to_bytes().await;
        let response: ApiResponse<queues::FetchData> = serde_json::from_slice(&body).unwrap();
        let data: queues::FetchData = response.data.unwrap();
        assert_eq!(data.queue.summary, "A queue of test problems");
    }

    #[sqlx::test(fixtures("seeds"))]
    async fn next_task(pool: SqlitePool) {
        let router = setup(pool).await;
        let queue_id = "2df309a7-8ece-4a14-a5f5-49699d2cba54";

        let response = router
            .oneshot(
                Request::builder()
                    .uri(format!("/api/v1/queues/{queue_id}/next-task"))
                    .method("GET")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);
        let body = response.to_bytes().await;
        let response: ApiResponse<queues::NextTaskData> = serde_json::from_slice(&body).unwrap();
        assert!(response.data.is_some());
    }

    #[sqlx::test(fixtures("seeds"))]
    async fn list_tasks(pool: SqlitePool) {
        let router = setup(pool).await;

        let response = router
            .oneshot(
                Request::builder()
                    .uri("/api/v1/tasks".to_string())
                    .method("GET")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);
        let body = response.to_bytes().await;
        let response: ApiResponse<tasks::ListData> = serde_json::from_slice(&body).unwrap();
        assert!(response.data.is_some());
    }

    #[sqlx::test(fixtures("seeds"))]
    async fn fetch_task(pool: SqlitePool) {
        let router = setup(pool).await;
        let task_id = "5bfdf4f7-c0bf-48eb-aa89-5643314738ec";

        let response = router
            .oneshot(
                Request::builder()
                    .uri(format!("/api/v1/tasks/{task_id}"))
                    .method("GET")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);
        let body = response.to_bytes().await;
        let response: ApiResponse<tasks::FetchData> = serde_json::from_slice(&body).unwrap();
        assert!(response.data.is_some());
    }
}
