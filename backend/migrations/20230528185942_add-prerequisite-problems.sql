create table prerequisite_problems (
  problem_id text not null,
  prerequisite_problem_id text not null,
  foreign key(problem_id) references problems(id),
  foreign key(prerequisite_problem_id) references problems(id)
);

alter table problems_skills rename to prerequisite_skills;
