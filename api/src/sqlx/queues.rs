use crate::types::{ApiError, Cadence, Queue, QueueStrategy, Result};
use sqlx::SqlitePool;

#[derive(sqlx::FromRow)]
struct QueueRow {
    pub id: String,
    pub summary: String,
    pub strategy: String,
    pub target_approach_id: String,
    pub cadence: String,
}

impl TryFrom<QueueRow> for Queue {
    type Error = ApiError;

    fn try_from(row: QueueRow) -> std::result::Result<Self, Self::Error> {
        let strategy = row.strategy.parse::<QueueStrategy>()?;
        let cadence = row.cadence.parse::<Cadence>()?;

        Ok(Self {
            id: row.id,
            summary: row.summary,
            strategy,
            target_approach_id: row.target_approach_id,
            cadence,
        })
    }
}

pub async fn fetch_all(db: &SqlitePool, user_id: &String, limit: i32) -> Result<Vec<Queue>> {
    let rows = sqlx::query_as::<_, QueueRow>("select * from queues where user_id = $1 limit $2")
        .bind(user_id)
        .bind(limit)
        .fetch_all(db)
        .await?;

    rows.into_iter()
        .map(|row| row.try_into())
        .collect::<Result<Vec<Queue>>>()
}
