use axum::{
    extract::rejection::JsonRejection,
    response::{IntoResponse, Response},
    Json,
};
use axum_macros::FromRequest;
use chrono::{DateTime, TimeDelta, Utc};
use hyper::StatusCode;
use serde::{ser::SerializeMap, Deserialize, Serialize};
use sqlx::migrate::MigrateError;
use std::{fmt::Display, str::FromStr};
use thiserror::Error;
use tracing::warn;

#[derive(Error, Debug)]
pub enum ApiError {
    #[error("unknown format: {0}")]
    ChronoParseError(#[from] chrono::ParseError),

    #[error("failed to load config")]
    Config(#[from] envy::Error),

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

#[derive(Debug, Deserialize, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub enum ApiErrorLevel {
    Error,
    Info,
    Warn,
}

#[derive(Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiErrorData {
    pub message: String,
    pub level: ApiErrorLevel,
}

#[derive(Debug, Deserialize)]
pub struct ApiResponse<T> {
    pub data: Option<T>,
    pub errors: Vec<ApiErrorData>,
}

impl<T> ApiResponse<T> {
    pub fn data(data: T) -> Self {
        Self {
            data: Some(data),
            errors: vec![],
        }
    }
}

impl ApiResponse<String> {
    pub fn ok() -> Self {
        Self {
            data: Some(String::from("ok")),
            errors: vec![],
        }
    }
}

impl<T> Serialize for ApiResponse<T>
where
    T: Serialize,
{
    fn serialize<S>(&self, serializer: S) -> std::result::Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        let mut map = serializer.serialize_map(Some(2))?;
        map.serialize_entry("data", &self.data)?;
        map.serialize_entry("errors", &self.errors)?;
        map.end()
    }
}

#[derive(Debug, Deserialize, FromRequest)]
#[from_request(via(axum::Json), rejection(ApiError))]
pub struct ApiJson<T>(pub T);

impl<T> IntoResponse for ApiJson<T>
where
    axum::Json<T>: IntoResponse,
{
    fn into_response(self) -> Response {
        axum::Json(self.0).into_response()
    }
}

impl ApiJson<ApiResponse<String>> {
    pub(crate) fn ok() -> Self {
        Self(ApiResponse::ok())
    }
}

pub type ApiOk = ApiJson<ApiResponse<String>>;

impl IntoResponse for ApiError {
    fn into_response(self) -> axum::response::Response {
        let (status, error) = match self {
            Self::ChronoParseError(err) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                ApiErrorData {
                    message: err.to_string(),
                    level: ApiErrorLevel::Error,
                },
            ),

            Self::Database(message) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                ApiErrorData {
                    message,
                    level: ApiErrorLevel::Error,
                },
            ),

            Self::Config(err) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                ApiErrorData {
                    message: err.to_string(),
                    level: ApiErrorLevel::Error,
                },
            ),

            Self::SqlxError(err) => match err {
                sqlx::Error::RowNotFound => (
                    StatusCode::NOT_FOUND,
                    ApiErrorData {
                        message: "Not found".into(),
                        level: ApiErrorLevel::Error,
                    },
                ),

                _ => {
                    warn!("{}", &err);
                    (
                        StatusCode::INTERNAL_SERVER_ERROR,
                        ApiErrorData {
                            message: err.to_string(),
                            level: ApiErrorLevel::Error,
                        },
                    )
                }
            },

            Self::MigrateError(err) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                ApiErrorData {
                    message: err.to_string(),
                    level: ApiErrorLevel::Error,
                },
            ),

            Self::General(err) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                ApiErrorData {
                    message: err.to_string(),
                    level: ApiErrorLevel::Error,
                },
            ),

            Self::NotFound => (
                StatusCode::NOT_FOUND,
                ApiErrorData {
                    message: "Not found".into(),
                    level: ApiErrorLevel::Info,
                },
            ),

            Self::UnprocessableEntity(message) => (
                StatusCode::UNPROCESSABLE_ENTITY,
                ApiErrorData {
                    message,
                    level: ApiErrorLevel::Warn,
                },
            ),

            Self::JsonExtractorRejection(rejection) => (
                StatusCode::BAD_REQUEST,
                ApiErrorData {
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

#[derive(Debug, Deserialize, Eq, Ord, PartialEq, PartialOrd, Serialize)]
pub struct Timestamp(pub(crate) DateTime<Utc>);

impl From<DateTime<Utc>> for Timestamp {
    fn from(value: DateTime<Utc>) -> Self {
        Self(value)
    }
}

impl FromStr for Timestamp {
    type Err = ApiError;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        Ok(Self(s.parse::<DateTime<Utc>>()?))
    }
}

impl Timestamp {
    pub fn now() -> Self {
        Self(Utc::now())
    }
    pub fn from_timestamp(timestamp: i64) -> Option<Self> {
        DateTime::<Utc>::from_timestamp(timestamp, 0).map(Self)
    }

    pub fn checked_add_signed(&self, delta: TimeDelta) -> Option<Self> {
        self.0.checked_add_signed(delta).map(Self)
    }

    pub fn to_iso_8601(&self) -> String {
        self.0.to_rfc3339()
    }
}

#[derive(Clone, Serialize, sqlx::FromRow)]
pub struct Skill {
    pub id: String,
    pub summary: String,
    pub description: Option<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub enum TaskAction {
    AcquireSkill,
    CompleteProblem,
    CompleteQuestion,
    CompleteSet,
}

impl FromStr for TaskAction {
    type Err = ApiError;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        match s {
            "acquireSkill" => Ok(Self::AcquireSkill),
            "completeProblem" => Ok(Self::CompleteProblem),
            "completeQuestion" => Ok(Self::CompleteQuestion),
            "completeSet" => Ok(Self::CompleteSet),
            _ => Err(ApiError::UnprocessableEntity(format!(
                "unknown action: {s}"
            ))),
        }
    }
}

#[derive(Clone, Debug, Deserialize, Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct Task {
    pub id: String,
    pub summary: String,
    pub action: TaskAction,
}

#[derive(Clone, Debug, Deserialize, Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct Approach {
    pub unspecified: bool,
    pub id: String,
    pub task_id: String,
    pub summary: String,
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

#[derive(Copy, Clone, Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub enum QueueStrategy {
    Deterministic,
    SpacedRepetitionV1,
}

impl Display for QueueStrategy {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let value = match self {
            Self::SpacedRepetitionV1 => "spacedRepetitionV1",
            Self::Deterministic => "deterministic",
        };
        write!(f, "{}", value)
    }
}

impl FromStr for QueueStrategy {
    type Err = ApiError;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        match s {
            "spacedRepetitionV1" => Ok(Self::SpacedRepetitionV1),
            _ => Err(ApiError::UnprocessableEntity(
                "unknown chooser: ".to_string(),
            )),
        }
    }
}

#[derive(Clone, Deserialize, Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct Queue {
    pub id: String,
    pub summary: String,
    pub strategy: QueueStrategy,
    pub target_approach_id: String,
    pub cadence: Cadence,
}

#[derive(Clone, Serialize, sqlx::FromRow)]
#[serde(rename_all = "camelCase")]
pub struct WideQueue {
    #[serde(flatten)]
    pub queue: Queue,
    pub answer_connection: AnswerConnection,
}

#[derive(Clone, Copy, Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub enum Cadence {
    Minutes,
    Hours,
}

impl Display for Cadence {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let value = match self {
            Self::Minutes => "minutes",
            Self::Hours => "hours",
        };
        f.write_str(value)
    }
}

impl FromStr for Cadence {
    type Err = ApiError;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        match s {
            "minutes" => Ok(Self::Minutes),
            "hours" => Ok(Self::Hours),
            _ => Err(ApiError::UnprocessableEntity(format!(
                "unknown cadence: {s}"
            ))),
        }
    }
}

#[derive(Debug)]
pub struct Clock {
    pub(crate) now: Timestamp,
    cadence: Cadence,
}

impl Clock {
    #[allow(dead_code)]
    pub fn new(cadence: Cadence) -> Self {
        Self {
            now: Timestamp::from_timestamp(0).unwrap(),
            cadence,
        }
    }

    pub fn now(cadence: Cadence) -> Self {
        Self {
            now: Timestamp::now(),
            cadence,
        }
    }

    #[allow(dead_code)]
    pub fn ticks(&self, n: i32) -> Option<Self> {
        let ticks = self.one_tick().checked_mul(n)?;
        let now = self.now.checked_add_signed(ticks)?;

        Some(Self {
            now,
            cadence: self.cadence,
        })
    }

    #[allow(dead_code)]
    fn one_tick(&self) -> TimeDelta {
        match self.cadence {
            Cadence::Minutes => TimeDelta::minutes(1),
            Cadence::Hours => TimeDelta::hours(1),
        }
    }
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub enum OutcomeType {
    Completed,
    NeedsRetry,
    TooHard,
}

impl OutcomeType {
    pub fn next_available_at(
        &self,
        clock: &Clock,
        answered_at: &Timestamp,
        consecutive_correct: u32,
    ) -> Result<Timestamp> {
        let n = match self {
            Self::TooHard => 90,
            _ => 2i32.pow(consecutive_correct),
        };
        debug_assert!(n > 0, "expected 1 or more ticks");

        let delta = clock
            .one_tick()
            .checked_mul(n)
            .ok_or_else(|| ApiError::General(format!("invalid duration: {n} ticks")))?;

        answered_at
            .checked_add_signed(delta)
            .ok_or_else(|| ApiError::General(String::from("date shift failed")))
    }
}
