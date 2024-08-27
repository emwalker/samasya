use super::approaches;
use crate::{
    problems::Search,
    types::{Problem, Result, WideProblem},
};
use sqlx::{sqlite::SqlitePool, QueryBuilder, Sqlite};

pub async fn list(db: &SqlitePool, limit: i32, search: Search) -> Result<Vec<Problem>> {
    let problems = if search.is_empty() {
        sqlx::query_as::<_, Problem>("select * from problems order by added_at desc limit ?")
            .bind(limit)
            .fetch_all(db)
            .await?
    } else {
        let mut builder: QueryBuilder<Sqlite> = QueryBuilder::new("select p.* from problems p ");
        let mut wheres = vec![];

        for (i, substring) in search.substrings().enumerate() {
            builder.push(format!("join problems p{i} on p.id = p{i}.id "));
            wheres.push(substring);
        }

        builder.push("where ");
        let mut separated = builder.separated(" and ");

        for (i, substring) in wheres.into_iter().enumerate() {
            separated.push(format!("lower(p{i}.summary) like '%'||lower("));
            separated.push_bind_unseparated(substring);
            separated.push_unseparated(")||'%'");
        }

        builder
            .push("order by p.added_at desc limit ")
            .push_bind(limit);
        builder.build_query_as::<Problem>().fetch_all(db).await?
    };

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
