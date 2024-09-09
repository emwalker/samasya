use std::str::FromStr;

use crate::{
    types::{ApiError, ApiJson, ApiResponse, Result, Search},
    ApiContext,
};
use axum::{extract::Query, Extension};
use serde::{Deserialize, Serialize};
use sqlx::{QueryBuilder, Sqlite};

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub enum SearchItemType {
    Queue,
    Task,
}

impl FromStr for SearchItemType {
    type Err = ApiError;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        match s {
            "queue" => Ok(Self::Queue),
            "task" => Ok(Self::Task),
            _ => Err(ApiError::UnprocessableEntity(format!("unknown type: {s}"))),
        }
    }
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct SearchItem {
    #[serde(rename = "type")]
    kind: SearchItemType,
    summary: String,
    id: String,
}

#[derive(sqlx::FromRow)]
struct SearchItemRow {
    kind: String,
    summary: String,
    id: String,
}

impl TryFrom<SearchItemRow> for SearchItem {
    type Error = ApiError;

    fn try_from(
        SearchItemRow { kind, summary, id }: SearchItemRow,
    ) -> std::result::Result<Self, Self::Error> {
        Ok(Self {
            kind: kind.parse::<SearchItemType>()?,
            summary,
            id,
        })
    }
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct SearchData {
    pub results: Vec<SearchItem>,
}

pub async fn search(
    ctx: Extension<ApiContext>,
    search: Option<Query<Search>>,
) -> Result<ApiJson<ApiResponse<SearchData>>> {
    let Some(search) = search else {
        return Ok(ApiJson(ApiResponse::data(SearchData { results: vec![] })));
    };

    let mut builder: QueryBuilder<Sqlite> = QueryBuilder::new(
        "select kind, summary, id
         from (
            select distinct 'task' kind, t.*
            from tasks t ",
    );
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

    builder.push(
        ")
        
         union
        
        select kind, summary, id
        from (
            select distinct 'queue' kind, q.*
            from queues q ",
    );
    let mut wheres = vec![];

    for (i, substring) in search.substrings().enumerate() {
        builder.push(format!("join queues q{i} on q.id = q{i}.id "));
        wheres.push(substring);
    }

    builder.push("where ");
    let mut separated = builder.separated(" and ");

    for (i, substring) in wheres.into_iter().enumerate() {
        separated.push(format!("lower(q{i}.summary) like '%'||lower("));
        separated.push_bind_unseparated(substring);
        separated.push_unseparated(")||'%'");
    }

    builder.push(") order by summary limit ").push_bind(20);
    let results = builder
        .build_query_as::<SearchItemRow>()
        .fetch_all(&ctx.db)
        .await?
        .into_iter()
        .map(SearchItem::try_from)
        .collect::<Result<Vec<_>>>()?;

    Ok(ApiJson(ApiResponse::data(SearchData { results })))
}
