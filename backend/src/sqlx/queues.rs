use crate::types::{Error, Queue, Result};
use sqlx::SqlitePool;

pub async fn fetch_all(db: &SqlitePool, user_id: &String, limit: i32) -> Result<Vec<Queue>> {
    sqlx::query_as::<_, Queue>("select * from queues where user_id = $1 limit $2")
        .bind(user_id)
        .bind(limit)
        .fetch_all(db)
        .await
        .map_err(|err| Error::Database(err.to_string()))
}
