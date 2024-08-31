pragma foreign_keys=off;

alter table prereq_skills rename to _prereq_skills;

create table prereq_skills (
  problem_id text not null,
  approach_id text,
  prereq_skill_id text not null,
  foreign key(problem_id) references problems(id),
  foreign key(approach_id) references approaches(id),
  foreign key(prereq_skill_id) references skills(id)
);

insert into prereq_skills
  select a.problem_id, ps.*
  from _prereq_skills ps
  join approaches a on ps.approach_id = a.id;

drop table _prereq_skills;

pragma foreign_keys=on;

