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

pub const PLACEHOLDER_USER_ID: &str = "04e229c9-795e-4f3a-a79e-ec18b5c28b99";
pub const PLACEHOLDER_ORGANIZATION_ID: &str = "407a4662-8f72-4883-a87c-f6e3649b2b89";
pub const PLACEHOLDER_REPO_ID: &str = "bfeea3c3-1160-488f-aac7-16919b6da713";
pub const PLACEHOLDER_REPO_CATEGORY_ID: &str = "9f31bf67-29b6-43c9-8b4c-3bdb77e959a7";
pub const PLACEHOLDER_REPO_TRACK_ID: &str = "e10fa49d-57a2-41a8-af68-7ea1b0b470ca";

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
