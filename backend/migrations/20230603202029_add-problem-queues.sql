create table users (
  created_at timestamp not null,
  id text primary key not null,
  updated_at timestamp not null default current_timestamp
);

insert into users (id, created_at)
  values ('04e229c9-795e-4f3a-a79e-ec18b5c28b99', current_timestamp);

create table queues (
  created_at timestamp not null,
  id text primary key not null,
  strategy integer not null default 1,
  summary text not null,
  target_problem_id text not null,
  updated_at timestamp not null default current_timestamp,
  user_id text not null,
  foreign key(target_problem_id) references problems(id),
  foreign key(user_id) references users(id)
);

create table answers (
  choice_id text not null,
  created_at timestamp not null,
  id text primary key not null,
  problem_id text not null,
  queue_id text not null,
  state integer not null,
  updated_at timestamp not null default current_timestamp,
  user_id text not null,
  foreign key(problem_id) references problems(id),
  foreign key(queue_id) references queues(id),
  foreign key(user_id) references users(id)
);
