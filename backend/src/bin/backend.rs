use axum::{routing::get, Json, Router};
use serde::Serialize;

#[derive(Serialize)]
struct Skill {
    description: String,
}

#[derive(Serialize)]
struct SkillsListResponse {
    data: Vec<Skill>,
}

async fn root() -> &'static str {
    "Hello, World!"
}

#[axum_macros::debug_handler]
async fn list_skills() -> Json<SkillsListResponse> {
    Json(SkillsListResponse {
        data: vec![
            Skill {
                description: "Basic statistics".into(),
            },
            Skill {
                description: "Addition of complex numbers".into(),
            },
        ],
    })
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let app = Router::new()
        .route("/", get(root))
        .route("/skills", get(list_skills));

    axum::Server::bind(&"0.0.0.0:8000".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}
