alter table prereq_problems
  add column added_at datetime default current_timestamp;
