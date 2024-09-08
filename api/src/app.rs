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
        .route(
            "/api/v1/approaches/:id/prereqs/available",
            get(approaches::prereqs::available),
        )
        .route("/api/v1/queues/:id", get(queues::fetch))
        .route("/api/v1/queues/:id", put(queues::update))
        .route("/api/v1/queues/:id/add-outcome", post(queues::add_outcome))
        .route(
            "/api/v1/queues/:id/available-tracks",
            get(queues::available_tracks),
        )
        .route("/api/v1/queues/:id/add-track", post(queues::add_track))
        .route("/api/v1/queues/:id/next-task", get(queues::next_task))
        .route(
            "/api/v1/queues/:id/remove-track",
            post(queues::remove_track),
        )
        .route("/api/v1/tasks", get(tasks::list))
        .route("/api/v1/tasks", post(tasks::add))
        .route("/api/v1/tasks/:id", get(tasks::fetch))
        .route("/api/v1/tasks/:id", put(tasks::update))
        .route("/api/v1/tasks/:id/prereqs/add", post(tasks::prereqs::add))
        .route(
            "/api/v1/tasks/:id/prereqs/remove",
            post(tasks::prereqs::remove),
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
        types::{Cadence, OutcomeType, QueueStrategy},
        PLACEHOLDER_REPO_CATEGORY_ID, PLACEHOLDER_REPO_TRACK_ID, PLACEHOLDER_USER_ID,
    };

    use super::*;
    use axum::{
        body::{Body, HttpBody},
        http::{Request, StatusCode},
    };
    use queues::{AddOutcomePayload, QueueRow};
    use sqlx::SqlitePool;
    use tempfile::tempdir;
    use tower::ServiceExt;
    use uuid::Uuid;

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

    async fn setup(db: &SqlitePool) -> Router {
        let path = tempdir()
            .unwrap()
            .path()
            .join("test.db")
            .into_os_string()
            .into_string()
            .unwrap();

        router(Config::with_database(path), db.clone())
            .await
            .unwrap()
    }

    #[sqlx::test]
    async fn root(pool: SqlitePool) {
        let router = setup(&pool).await;

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
        let router = setup(&pool).await;

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
        let router = setup(&pool).await;
        let user_id = PLACEHOLDER_USER_ID;

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
        let router = setup(&pool).await;
        let user_id = PLACEHOLDER_USER_ID;

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

    #[sqlx::test(fixtures("seeds", "simple"))]
    async fn fetch_queue(pool: SqlitePool) {
        let router = setup(&pool).await;
        let queue_id = "34b1de9d-ac94-433c-8369-0e121e97af43";

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
        assert_eq!(data.queue.summary, "David Tolnay's Rust quiz");
        assert_eq!(
            data.target_task.summary,
            "Ability to complete David Tolnay's Rust Quiz without mistakes"
        );
        assert_eq!(data.target_approach.summary, "Unspecified");
        assert!(!data.outcomes.is_empty());
        assert!(!data.tracks.is_empty());
    }

    #[sqlx::test(fixtures("seeds", "simple"))]
    async fn update_queue(pool: SqlitePool) {
        let router = setup(&pool).await;
        let queue_id = "34b1de9d-ac94-433c-8369-0e121e97af43";
        let payload = queues::UpdatePayload {
            queue_id: String::from(queue_id),
            summary: String::from("Updated queue summary"),
            cadence: Cadence::Days,
            strategy: QueueStrategy::SpacedRepetitionV1,
        };
        let payload = serde_json::to_string(&payload).unwrap();

        let response = router
            .oneshot(
                Request::builder()
                    .uri(format!("/api/v1/queues/{queue_id}"))
                    .method("PUT")
                    .header("Content-Type", "application/json")
                    .body(Body::from(payload))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);

        let queue = sqlx::query_as::<_, QueueRow>("select * from queues where id = ?")
            .bind(queue_id)
            .fetch_one(&pool)
            .await
            .unwrap();
        assert_eq!(queue.summary, "Updated queue summary");
    }

    #[sqlx::test(fixtures("seeds", "simple"))]
    async fn next_task(pool: SqlitePool) {
        let router = setup(&pool).await;
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
        let data: queues::NextTaskData = response.data.unwrap();
        assert!(matches!(data.details, queues::NextTask::Ready { .. }));
        let queues::NextTask::Ready { task_id, .. } = data.details else {
            panic!();
        };
        assert_eq!(task_id, "c7299bc0-8604-4469-bec7-c449ba1bf060");
    }

    #[sqlx::test(fixtures("seeds", "simple"))]
    async fn add_outcome(pool: SqlitePool) {
        let router = setup(&pool).await;
        let queue_id = "2df309a7-8ece-4a14-a5f5-49699d2cba54";
        let payload = AddOutcomePayload {
            queue_id: queue_id.into(),
            approach_id: "3a8c4401-4ef4-48d6-b192-99ad9cd5ea37".into(),
            repo_track_id: PLACEHOLDER_REPO_TRACK_ID.into(),
            outcome: OutcomeType::Completed,
        };
        let payload = serde_json::to_string(&payload).unwrap();

        let response = router
            .oneshot(
                Request::builder()
                    .uri(format!("/api/v1/queues/{queue_id}/add-outcome"))
                    .method("POST")
                    .header("Content-Type", "application/json")
                    .body(Body::from(payload))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);
        let body = response.to_bytes().await;
        let response: ApiResponse<queues::AddOutcomeData> = serde_json::from_slice(&body).unwrap();
        assert!(response.data.is_some());
    }

    #[sqlx::test(fixtures("seeds"))]
    async fn available_tracks(pool: SqlitePool) {
        let router = setup(&pool).await;
        let queue_id = "2df309a7-8ece-4a14-a5f5-49699d2cba54";

        let response = router
            .oneshot(
                Request::builder()
                    .uri(format!("/api/v1/queues/{queue_id}/available-tracks?q=R"))
                    .method("GET")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        // assert_eq!(response.status(), StatusCode::OK);
        let body = response.to_bytes().await;
        let response: ApiResponse<queues::AvailableTracksData> =
            serde_json::from_slice(&body).unwrap();
        let data = response.data.unwrap();
        assert_eq!(data.first().unwrap().track_name, "Rust");
    }

    #[sqlx::test(fixtures("seeds", "simple"))]
    async fn add_track(pool: SqlitePool) {
        let router = setup(&pool).await;
        let queue_id = "2df309a7-8ece-4a14-a5f5-49699d2cba54";
        let payload = queues::AddTrackPayload {
            queue_id: String::from(queue_id),
            category_id: String::from(PLACEHOLDER_REPO_CATEGORY_ID),
            track_id: String::from(PLACEHOLDER_REPO_TRACK_ID),
        };
        let payload = serde_json::to_string(&payload).unwrap();

        let response = router
            .oneshot(
                Request::builder()
                    .uri(format!("/api/v1/queues/{queue_id}/add-track"))
                    .method("POST")
                    .header("Content-Type", "application/json")
                    .body(Body::from(payload))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);
        let body = response.to_bytes().await;
        let response: ApiResponse<String> = serde_json::from_slice(&body).unwrap();
        assert_eq!(response.data.unwrap(), "ok");
    }

    #[sqlx::test(fixtures("seeds", "simple"))]
    async fn remove_track(pool: SqlitePool) {
        let router = setup(&pool).await;
        let new_id: String = Uuid::new_v4().into();
        let queue_id = "2df309a7-8ece-4a14-a5f5-49699d2cba54";

        sqlx::query(
            "insert into queue_tracks
                (id, queue_id, repo_category_id, repo_track_id)
                values (?, ?, ?, ?)",
        )
        .bind(&new_id)
        .bind(queue_id)
        .bind(PLACEHOLDER_REPO_CATEGORY_ID)
        .bind(PLACEHOLDER_REPO_TRACK_ID)
        .execute(&pool)
        .await
        .unwrap();

        let payload = queues::RemoveTrackPayload {
            queue_id: String::from(queue_id),
            track_id: String::from(PLACEHOLDER_REPO_TRACK_ID),
        };
        let payload = serde_json::to_string(&payload).unwrap();

        let response = router
            .oneshot(
                Request::builder()
                    .uri(format!("/api/v1/queues/{queue_id}/remove-track"))
                    .method("POST")
                    .header("Content-Type", "application/json")
                    .body(Body::from(payload))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);
        let body = response.to_bytes().await;
        let response: ApiResponse<String> = serde_json::from_slice(&body).unwrap();
        assert_eq!(response.data.unwrap(), "ok");
    }

    #[sqlx::test(fixtures("seeds"))]
    async fn list_tasks(pool: SqlitePool) {
        let router = setup(&pool).await;

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
    async fn search_tasks(pool: SqlitePool) {
        let router = setup(&pool).await;

        let response = router
            .oneshot(
                Request::builder()
                    .uri("/api/v1/tasks?q=D".to_string())
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
        let router = setup(&pool).await;
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

    #[sqlx::test(fixtures("seeds"))]
    async fn add_task(pool: SqlitePool) {
        let router = setup(&pool).await;
        let task_id = "c7299bc0-8604-4469-bec7-c449ba1bf060";
        let data = tasks::prereqs::AddPayload {
            task_id: task_id.to_string(),
            approach_id: String::from("81359cd2-ec5f-498f-b9c4-281a1d034e59"),
            prereq_task_id: String::from("ad6f42a7-45c2-4029-806f-5231cb3e9abb"),
            prereq_approach_id: String::from("b5f55bb7-8dd9-4a64-bda4-11df290902b2"),
        };
        let payload: String = serde_json::to_string(&data).unwrap();

        let response = router
            .oneshot(
                Request::builder()
                    .uri(format!("/api/v1/tasks/{task_id}/prereqs/add"))
                    .header("Content-Type", "application/json")
                    .method("POST")
                    .body(Body::from(payload))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);
        let body = response.to_bytes().await;
        let response: ApiResponse<String> = serde_json::from_slice(&body).unwrap();
        assert_eq!(response.data, Some("ok".into()));
    }

    #[sqlx::test(fixtures("seeds"))]
    async fn available_prereqs(pool: SqlitePool) {
        let router = setup(&pool).await;
        let approach_id = "c7299bc0-8604-4469-bec7-c449ba1bf060";

        let response = router
            .oneshot(
                Request::builder()
                    .uri(format!(
                        "/api/v1/approaches/{approach_id}/prereqs/available?q=A"
                    ))
                    .method("GET")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        // assert_eq!(response.status(), StatusCode::OK);
        let body = response.to_bytes().await;
        let response: ApiResponse<approaches::prereqs::ListData> =
            serde_json::from_slice(&body).unwrap();
        assert!(!response.data.unwrap().is_empty());
    }

    #[sqlx::test(fixtures("seeds", "simple"))]
    async fn fetch_approach(pool: SqlitePool) {
        let router = setup(&pool).await;
        let approach_id = "81359cd2-ec5f-498f-b9c4-281a1d034e59";

        let response = router
            .oneshot(
                Request::builder()
                    .uri(format!("/api/v1/approaches/{approach_id}"))
                    .method("GET")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);
        let body = response.to_bytes().await;
        let response: ApiResponse<approaches::FetchData> = serde_json::from_slice(&body).unwrap();
        let data: approaches::FetchData = response.data.unwrap();
        assert_eq!(data.approach.id, approach_id);
        assert_eq!(data.task.id, data.approach.task_id);
    }
}
