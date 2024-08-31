use axum::{extract::rejection::JsonRejection, response::IntoResponse, Json};
use chrono::{DateTime, TimeDelta, Utc};
use hyper::StatusCode;
use serde::{ser::SerializeMap, Deserialize, Serialize};
use sqlx::migrate::MigrateError;
use thiserror::Error;
use tracing::warn;

#[derive(Error, Debug)]
pub enum ApiError {
    #[error("failed to load config")]
    Config(String),

    #[error("sqlx error: {0}")]
    SqlxError(#[from] sqlx::Error),

    #[error("failed to connect to database: {0}")]
    Database(String),

    #[error("there was a problem: {0}")]
    General(String),

    #[error("failed to prepare database: {0}")]
    MigrateError(#[from] MigrateError),

    #[error("not found")]
    NotFound,

    #[error("bad input")]
    UnprocessableEntity(String),

    #[error(transparent)]
    JsonExtractorRejection(#[from] JsonRejection),
}

#[derive(Serialize)]
enum ApiErrorLevel {
    #[serde(rename = "error")]
    Error,
    #[allow(dead_code)]
    #[serde(rename = "info")]
    Info,
    #[allow(dead_code)]
    #[serde(rename = "warning")]
    Warn,
}

#[derive(Serialize)]
pub struct ApiErrorResponse {
    #[allow(dead_code)]
    message: String,
    #[allow(dead_code)]
    level: ApiErrorLevel,
}

struct ApiResponse<T> {
    #[allow(dead_code)]
    data: Option<T>,
    #[allow(dead_code)]
    errors: Vec<ApiErrorResponse>,
}

impl<T> Serialize for ApiResponse<T> {
    fn serialize<S>(&self, serializer: S) -> std::result::Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        let mut map = serializer.serialize_map(Some(2))?;
        let value: Option<String> = None;
        map.serialize_entry("data", &value)?;
        map.serialize_entry("errors", &self.errors)?;
        map.end()
    }
}

impl IntoResponse for ApiError {
    fn into_response(self) -> axum::response::Response {
        let (status, error) = match self {
            Self::Database(message) | Self::Config(message) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                ApiErrorResponse {
                    message,
                    level: ApiErrorLevel::Error,
                },
            ),

            Self::SqlxError(err) => match err {
                sqlx::Error::RowNotFound => (
                    StatusCode::NOT_FOUND,
                    ApiErrorResponse {
                        message: "Not found".into(),
                        level: ApiErrorLevel::Error,
                    },
                ),

                _ => {
                    warn!("{}", &err);
                    (
                        StatusCode::INTERNAL_SERVER_ERROR,
                        ApiErrorResponse {
                            message: err.to_string(),
                            level: ApiErrorLevel::Error,
                        },
                    )
                }
            },

            Self::MigrateError(err) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                ApiErrorResponse {
                    message: err.to_string(),
                    level: ApiErrorLevel::Error,
                },
            ),

            Self::General(err) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                ApiErrorResponse {
                    message: err.to_string(),
                    level: ApiErrorLevel::Error,
                },
            ),

            Self::NotFound => (
                StatusCode::NOT_FOUND,
                ApiErrorResponse {
                    message: "Not found".into(),
                    level: ApiErrorLevel::Info,
                },
            ),

            Self::UnprocessableEntity(message) => (
                StatusCode::UNPROCESSABLE_ENTITY,
                ApiErrorResponse {
                    message,
                    level: ApiErrorLevel::Error,
                },
            ),

            Self::JsonExtractorRejection(rejection) => (
                StatusCode::BAD_REQUEST,
                ApiErrorResponse {
                    message: rejection.body_text(),
                    level: ApiErrorLevel::Error,
                },
            ),
        };

        let response: ApiResponse<String> = ApiResponse {
            data: None,
            errors: vec![error],
        };

        (status, Json(response)).into_response()
    }
}

pub type Result<T> = std::result::Result<T, ApiError>;

#[derive(Debug, Eq, Ord, PartialEq, PartialOrd)]
pub struct Timestamp(pub(crate) DateTime<Utc>);

impl From<DateTime<Utc>> for Timestamp {
    fn from(value: DateTime<Utc>) -> Self {
        Self(value)
    }
}

impl Timestamp {
    pub fn from_timestamp(timestamp: i64) -> Option<Self> {
        DateTime::<Utc>::from_timestamp(timestamp, 0).map(Self)
    }

    pub fn checked_add_signed(&self, delta: TimeDelta) -> Option<Self> {
        self.0.checked_add_signed(delta).map(Self)
    }
}

#[derive(Clone, Serialize, sqlx::FromRow)]
pub struct Skill {
    pub id: String,
    pub summary: String,
    pub description: Option<String>,
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

#[derive(Clone, Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct Answer {}

#[derive(Clone, Serialize)]
pub struct AnswerEdge {
    pub node: Answer,
}
#[derive(Clone, Serialize)]
pub struct AnswerConnection {
    pub edges: Vec<AnswerEdge>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub enum QueueStrategy {
    Determistic = 0,
    SpacedRepetitionV1 = 1,
}

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Queue {
    pub id: String,
    pub summary: String,
    pub strategy: QueueStrategy,
    pub target_problem_id: String,
}

#[derive(Clone, Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct WideQueue {
    #[serde(flatten)]
    pub queue: Queue,
    pub answer_connection: AnswerConnection,
}
