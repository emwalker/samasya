use crate::types::{
    Answer, AnswerConnection, AnswerEdge, ApiError, Queue, QueueStrategy, Result, WideQueue,
};
use sqlx::SqlitePool;

#[derive(sqlx::FromRow)]
struct QueueRow {
    pub id: String,
    pub summary: String,
    pub strategy: i32,
}

impl TryFrom<QueueRow> for Queue {
    type Error = ApiError;

    fn try_from(value: QueueRow) -> std::result::Result<Self, Self::Error> {
        let strategy = match value.strategy {
            0 => QueueStrategy::Determistic,
            1 => QueueStrategy::SpacedRepetitionV1,
            other => return Err(ApiError::Database(format!("bad strategy: {}", other))),
        };

        Ok(Self {
            id: value.id,
            summary: value.summary,
            strategy,
        })
    }
}

pub async fn fetch_all(db: &SqlitePool, user_id: &String, limit: i32) -> Result<Vec<Queue>> {
    let rows = sqlx::query_as::<_, QueueRow>("select * from queues where user_id = $1 limit $2")
        .bind(user_id)
        .bind(limit)
        .fetch_all(db)
        .await
        .map_err(|err| ApiError::Database(err.to_string()))?;

    rows.into_iter()
        .map(|row| row.try_into())
        .collect::<Result<Vec<Queue>>>()
}

pub async fn fetch_wide(db: &SqlitePool, id: &String) -> Result<WideQueue> {
    let queue: Queue = sqlx::query_as::<_, QueueRow>("select * from queues where id = $1")
        .bind(id)
        .fetch_one(db)
        .await
        .map_err(|err| ApiError::Database(err.to_string()))?
        .try_into()?;

    let answers = sqlx::query_as::<_, Answer>("select * from answers where queue_id = $1 limit 20")
        .bind(id)
        .fetch_all(db)
        .await
        .map_err(|err| ApiError::Database(err.to_string()))?;

    let answer_connection = AnswerConnection {
        edges: answers
            .into_iter()
            .map(|answer| AnswerEdge { node: answer })
            .collect(),
    };

    Ok(WideQueue {
        queue,
        answer_connection,
    })
}
