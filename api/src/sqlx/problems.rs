use super::approaches;
use crate::types::{ApiError, Problem, Result, WideProblem};
use sqlx::sqlite::SqlitePool;

pub async fn fetch_all(db: &SqlitePool, limit: i32) -> Result<Vec<Problem>> {
    sqlx::query_as::<_, Problem>("select * from problems limit ?")
        .bind(limit)
        .fetch_all(db)
        .await
        .map_err(|err| ApiError::Database(err.to_string()))
}

pub async fn fetch_one(db: &SqlitePool, id: &String) -> Result<Problem> {
    sqlx::query_as::<_, Problem>("select * from problems where id = ? limit 1")
        .bind(id)
        .fetch_one(db)
        .await
        .map_err(|err| ApiError::Database(err.to_string()))
}

pub async fn fetch_wide(db: &SqlitePool, id: &String) -> Result<WideProblem> {
    let problem = sqlx::query_as::<_, Problem>("select * from problems where id = ? limit 1")
        .bind(id)
        .fetch_one(db)
        .await
        .map_err(|err| ApiError::Database(err.to_string()))?;

    let approach_ids =
        sqlx::query_as::<_, (String,)>("select id from approaches where problem_id = ?")
            .bind(id)
            .fetch_all(db)
            .await
            .map_err(|err| ApiError::Database(err.to_string()))?;

    let mut wide_approaches = vec![];
    for (approach_id,) in approach_ids {
        let approach = approaches::fetch_wide(db, &approach_id).await?;
        wide_approaches.push(approach);
    }

    Ok(WideProblem {
        problem,
        approaches: wide_approaches,
    })
}
