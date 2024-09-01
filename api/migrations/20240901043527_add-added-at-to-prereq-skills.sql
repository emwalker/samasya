pragma foreign_keys=off;

alter table prereq_skills rename to _prereq_skills;

create table prereq_skills (
  problem_id text not null,
  approach_id text,
  prereq_skill_id text not null,
  added_at datetime not null default current_timestamp,
  foreign key(problem_id) references problems(id),
  foreign key(approach_id) references approaches(id),
  foreign key(prereq_skill_id) references skills(id)
);

insert into prereq_skills
  select ps.*, current_timestamp added_at from _prereq_skills ps;

drop table _prereq_skills;

pragma foreign_keys=on;

