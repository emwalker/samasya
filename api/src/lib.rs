use crate::types::Result;
use ::sqlx::SqlitePool;
use serde::{Deserialize, Serialize};
use std::{env, sync::Arc};

pub mod app;
pub mod approaches;
pub mod queues;
pub mod sqlx;
pub mod tasks;
pub mod types;

pub const PLACHOLDER_USER_ID: &str = "04e229c9-795e-4f3a-a79e-ec18b5c28b99";
pub const PLACHOLDER_ORGANIZATION_ID: &str = "407a4662-8f72-4883-a87c-f6e3649b2b89";
pub const PLACHOLDER_REPO_ID: &str = "bfeea3c3-1160-488f-aac7-16919b6da713";

#[derive(Deserialize, Serialize)]
pub struct Config {
    pub db_filename: String,
}

impl Config {
    pub fn load() -> Result<Self> {
        let profile = env::var("ENV").unwrap_or("development".into());
        dotenv::from_filename(format!(".env.{}.local", profile)).ok();
        dotenv::dotenv().ok();
        Ok(envy::from_env::<Self>()?)
    }

    pub fn with_database(db_filename: String) -> Self {
        Config { db_filename }
    }
}

#[derive(Clone)]
pub struct ApiContext {
    pub config: Arc<Config>,
    pub db: SqlitePool,
}
