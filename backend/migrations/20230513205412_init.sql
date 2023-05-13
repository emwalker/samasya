-- Add migration script here
create table if not exists skills (
  id primary key,
  description text
);
