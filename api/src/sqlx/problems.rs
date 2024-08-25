use super::approaches;
use crate::types::{Problem, Result, WideProblem};
use sqlx::sqlite::SqlitePool;

pub async fn fetch_all(db: &SqlitePool, limit: i32) -> Result<Vec<Problem>> {
    let problems =
        sqlx::query_as::<_, Problem>("select * from problems order by added_at desc limit ?")
            .bind(limit)
            .fetch_all(db)
            .await?;
    Ok(problems)
}

pub async fn fetch_one(db: &SqlitePool, id: &String) -> Result<Problem> {
    let problem = sqlx::query_as::<_, Problem>("select * from problems where id = ? limit 1")
        .bind(id)
        .fetch_one(db)
        .await?;
    Ok(problem)
}

pub async fn fetch_wide(db: &SqlitePool, id: &String) -> Result<WideProblem> {
    let problem = sqlx::query_as::<_, Problem>("select * from problems where id = ? limit 1")
        .bind(id)
        .fetch_one(db)
        .await?;

    let approach_ids =
        sqlx::query_as::<_, (String,)>("select id from approaches where problem_id = ?")
            .bind(id)
            .fetch_all(db)
            .await?;

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
