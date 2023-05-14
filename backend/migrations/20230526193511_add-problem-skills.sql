create table problems_skills (
  problem_id text not null,
  skill_id text not null,
  foreign key(problem_id) references problems(id),
  foreign key(skill_id) references skills(id)
);
