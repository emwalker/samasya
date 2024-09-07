use crate::{
    tasks::{Search, TaskRow},
    types::{Result, Task},
};
use sqlx::{sqlite::SqlitePool, QueryBuilder, Sqlite};

pub async fn list(db: &SqlitePool, limit: i32, search: Search) -> Result<Vec<Task>> {
    let tasks = if search.is_empty() {
        sqlx::query_as::<_, TaskRow>("select * from tasks order by added_at desc limit ?")
            .bind(limit)
            .fetch_all(db)
            .await?
    } else {
        let mut builder: QueryBuilder<Sqlite> = QueryBuilder::new("select t.* from tasks t ");
        let mut wheres = vec![];

        for (i, substring) in search.substrings().enumerate() {
            builder.push(format!("join tasks t{i} on t.id = t{i}.id "));
            wheres.push(substring);
        }

        builder.push("where ");
        let mut separated = builder.separated(" and ");

        for (i, substring) in wheres.into_iter().enumerate() {
            separated.push(format!("lower(t{i}.summary) like '%'||lower("));
            separated.push_bind_unseparated(substring);
            separated.push_unseparated(")||'%'");
        }

        builder
            .push("order by t.added_at desc limit ")
            .push_bind(limit);
        builder.build_query_as::<TaskRow>().fetch_all(db).await?
    };

    tasks
        .into_iter()
        .map(Task::try_from)
        .collect::<Result<Vec<_>>>()
}

pub async fn fetch_one(db: &SqlitePool, id: &String) -> Result<Task> {
    let task: Task = sqlx::query_as::<_, TaskRow>("select * from problems where id = ? limit 1")
        .bind(id)
        .fetch_one(db)
        .await?
        .try_into()?;
    Ok(task)
}
