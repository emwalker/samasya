create table approaches (
  id text primary key,
  problem_id text not null,
  name text not null,
  "default" boolean not null default 1,
  foreign key(problem_id) references problems(id)
);

insert into approaches (id, problem_id, name, "default")
  select
    -- Generate a primary key
    lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) ||
    '-4' || substr(lower(hex(randomblob(2))),2) || '-' || substr('89ab',abs(random()) % 4 + 1, 1) ||
    substr(lower(hex(randomblob(2))),2) || '-' || lower(hex(randomblob(6))),
    id,
    'Default',
    1
  from problems;

alter table prerequisite_skills rename to prereq_skills_temp;

create table prereq_skills (
  approach_id text not null,
  prereq_skill_id text not null,
  foreign key(approach_id) references approaches(id),
  foreign key(prereq_skill_id) references skills(id)
);

insert into prereq_skills (approach_id, prereq_skill_id)
  select pa.id, ps.skill_id
  from prereq_skills_temp ps
  join approaches pa on ps.problem_id = pa.problem_id;

create table prereq_approaches (
  approach_id text not null,
  prereq_approach_id text not null,
  foreign key(approach_id) references approaches(id),
  foreign key(prereq_approach_id) references approaches(id)
);

insert into prereq_approaches
  (approach_id, prereq_approach_id)
  select pa1.id, pa2.id
    from prerequisite_problems pp
    -- Resolve problem_id to approaches(id)
    join approaches pa1 on pp.problem_id = pa1.problem_id
    -- Resolve prereq_problem_id to approaches(id)
    join approaches pa2 on pp.prerequisite_problem_id = pa2.problem_id;

drop table prereq_skills_temp;
drop table prerequisite_problems;

alter table problems rename description to question_text;
alter table problems add column question_url text;
alter table problems add column summary text;
update problems set summary = question_text;

alter table skills rename description to summary;

PRAGMA writable_schema = 1;
update sqlite_master set sql = 'CREATE TABLE problems (id primary key, question_text text, question_url text, summary text not null)'
  where name = 'problems';

update sqlite_master set sql = 'CREATE TABLE skills (id primary key, summary text not null)'
  where name = 'skills';
PRAGMA writable_schema = 0;
