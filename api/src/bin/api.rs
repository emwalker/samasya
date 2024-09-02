use samasya::{app, types::Result, Config};
use sqlx::sqlite::SqlitePoolOptions;

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();
    let config = Config::load()?;
    let db = SqlitePoolOptions::new()
        .max_connections(1)
        .connect(&format!("sqlite://{}?mode=rwc", config.db_filename))
        .await?;
    let router = app::router(config, db).await?;

    axum::Server::bind(&"0.0.0.0:8000".parse().unwrap())
        .serve(router.into_make_service())
        .await
        .unwrap();

    Ok(())
}
