alter table answers rename to _answers;

create table answers (
  id text primary key not null,
  added_at timestamp not null default current_timestamp,
  answered_at timestamp,
  problem_id text not null,
  approach_id text,
  queue_id text not null,
  state string check(state in ('unseen', 'correct', 'incorrect', 'unsure')) not null,
  user_id text not null,
  consecutive_correct number not null default 0,
  foreign key(queue_id) references queues(id),
  foreign key(user_id) references users(id),
  foreign key(problem_id) references problems(id),
  foreign key(approach_id) references approaches(id)
);

insert into answers select a.*, 0 consecutive_correct from _answers a;
drop table _answers;
