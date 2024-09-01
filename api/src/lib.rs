use crate::types::{ApiError, Result};
use ::sqlx::SqlitePool;
use serde::{Deserialize, Serialize};
use std::{env, sync::Arc};

pub mod approaches;
pub mod problems;
pub mod queues;
pub mod skills;
pub mod sqlx;
pub mod types;

pub const PLACHOLDER_USER_ID: &str = "04e229c9-795e-4f3a-a79e-ec18b5c28b99";

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
