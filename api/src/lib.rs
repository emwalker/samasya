use crate::types::Result;
use ::sqlx::SqlitePool;
use axum::response::{IntoResponse, Response};
use axum_macros::FromRequest;
use serde::{Deserialize, Serialize};
use std::{env, sync::Arc};
use types::ApiError;

pub mod skills;
pub mod sqlx;
pub mod types;

#[derive(Deserialize, Serialize)]
pub struct Config {
    pub db_filename: String,
}

impl Config {
    pub fn load() -> Result<Self> {
        let profile = env::var("ENV").unwrap_or("development".into());
        dotenv::from_filename(format!(".env.{}.local", profile)).ok();
        dotenv::dotenv().ok();
        envy::from_env::<Self>().map_err(|err| ApiError::Config(err.to_string()))
    }
}

#[derive(Clone)]
pub struct ApiContext {
    pub config: Arc<Config>,
    pub db: SqlitePool,
}

#[derive(FromRequest)]
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
