use super::problems;
use crate::types::{Approach, Error, Problem, Result, Skill, WideApproach};
use sqlx::sqlite::SqlitePool;

async fn add_relations(
    db: &SqlitePool,
    problem: &Problem,
    rows: Vec<Approach>,
) -> Result<Vec<WideApproach>> {
    let mut approaches: Vec<WideApproach> = vec![];

    for approach in rows {
        let prereq_skills = sqlx::query_as::<_, Skill>(
            "select s.*
             from skills s join prereq_skills ps on s.id = ps.prereq_skill_id
             where ps.approach_id = $1",
        )
        .bind(&approach.id)
        .fetch_all(db)
        .await
        .map_err(|err| Error::Database(err.to_string()))?;

        let prereq_approaches = sqlx::query_as::<_, Approach>(
            "select a.*, p.summary
             from approaches a
             join prereq_approaches pa on a.id = pa.prereq_approach_id
             join problems p on a.problem_id = p.id
             where pa.approach_id = $1",
        )
        .bind(&approach.id)
        .fetch_all(db)
        .await
        .map_err(|err| Error::Database(err.to_string()))?;

        approaches.push(WideApproach {
            approach,
            prereq_approaches,
            prereq_skills,
            problem: problem.clone(),
        })
    }

    Ok(approaches)
}

pub async fn fetch_all(db: &SqlitePool, problem_id: &String, limit: i32) -> Result<Vec<Approach>> {
    sqlx::query_as::<_, Approach>(
        "select a.*, p.summary
         from approaches a join problems p on a.problem_id = p.id
         where problem_id = $1
         limit $2",
    )
    .bind(problem_id)
    .bind(limit)
    .fetch_all(db)
    .await
    .map_err(|err| Error::Database(err.to_string()))
}

pub async fn fetch_wide(db: &SqlitePool, id: &str) -> Result<WideApproach> {
    let approach = sqlx::query_as::<_, Approach>(
        "select a.*, p.summary
         from approaches a
         join problems p on a.problem_id = p.id
         where a.id = ?
         limit 1",
    )
    .bind(id)
    .fetch_one(db)
    .await
    .map_err(|err| Error::Database(err.to_string()))?;

    let problem = problems::fetch_one(db, &approach.problem_id).await?;

    let mut wide_approaches = add_relations(db, &problem, vec![approach]).await?;
    if wide_approaches.len() == 1 {
        let approach = wide_approaches.pop().unwrap();
        return Ok(approach);
    }

    Err(Error::NotFound)
}
