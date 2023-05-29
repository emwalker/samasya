use axum::{response::IntoResponse, Json};
use hyper::StatusCode;
use serde::Serialize;
use serde_json::json;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum Error {
    #[error("failed to load config")]
    Config(String),
    #[error("failed to connect to database: {0}")]
    Database(String),
    #[error("not found")]
    NotFound,
    #[error("bad input")]
    UnprocessableEntity(String),
}

impl IntoResponse for Error {
    fn into_response(self) -> axum::response::Response {
        let (status, error_message) = match self {
            Self::Database(message) | Self::Config(message) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                format!("Internal server error: {}", message),
            ),

            Self::NotFound => (StatusCode::NOT_FOUND, "Not found".into()),

            Self::UnprocessableEntity(message) => (StatusCode::UNPROCESSABLE_ENTITY, message),
        };

        (status, Json(json!({ "error": error_message }))).into_response()
    }
}

pub type Result<T, E = Error> = std::result::Result<T, E>;

#[derive(Clone, Serialize, sqlx::FromRow)]
pub struct Skill {
    pub id: String,
    pub summary: String,
}

#[derive(Clone, Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct Problem {
    pub id: String,
    pub summary: String,
    pub question_text: Option<String>,
    pub question_url: Option<String>,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct WideProblem {
    #[serde(flatten)]
    pub problem: Problem,
    pub approaches: Vec<WideApproach>,
}

#[derive(Clone, Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct Approach {
    pub default: bool,
    pub id: String,
    pub name: String,
    #[serde(skip)]
    pub problem_id: String,
    pub summary: String,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct WideApproach {
    #[serde(flatten)]
    pub approach: Approach,
    pub prereq_approaches: Vec<Approach>,
    pub prereq_skills: Vec<Skill>,
    pub problem: Problem,
}
