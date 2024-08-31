-- Add migration script here
pragma foreign_keys=off;

alter table queues rename to _queues;

create table queues (
  created_at timestamp not null,
  id text primary key not null,
  strategy integer not null default 1,
  summary text not null,
  target_problem_id text not null,
  updated_at timestamp not null default current_timestamp,
  user_id text not null,
  target_approach_id text,
  foreign key(target_problem_id) references problems(id),
  foreign key(target_approach_id) references approaches(id),
  foreign key(user_id) references users(id)
);

insert into queues select *, null target_approach_id from _queues;
drop table _queues;

pragma foreign_keys=on;
