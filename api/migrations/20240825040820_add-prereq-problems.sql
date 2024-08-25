create table if not exists prereq_problems (
  skill_id text not null,
  prereq_problem_id text not null,
  prereq_approach_id text,
  foreign key(skill_id) references skills(id),
  foreign key(prereq_problem_id) references problems(id),
  foreign key(prereq_approach_id) references approaches(id)
);

create unique index if not exists prereq_problems_uniq_idx on prereq_problems
  (skill_id, prereq_problem_id, ifnull(prereq_approach_id, 0));
