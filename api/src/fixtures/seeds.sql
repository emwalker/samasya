PRAGMA foreign_keys=OFF;
CREATE TABLE users (
  created_at timestamp not null,
  id text primary key not null,
  updated_at timestamp not null default current_timestamp
);
INSERT INTO users VALUES('2023-06-03 21:01:18','04e229c9-795e-4f3a-a79e-ec18b5c28b99','2023-06-03 21:01:18');
CREATE TABLE organizations (
  id text primary key not null,
  owner_id text not null default '04e229c9-795e-4f3a-a79e-ec18b5c28b99',
  name text not null,
  name_slug text not null,
  added_at datetime not null default current_timestamp,
  foreign key(owner_id) references users(id),
  unique(name)
);
INSERT INTO organizations VALUES('407a4662-8f72-4883-a87c-f6e3649b2b89','04e229c9-795e-4f3a-a79e-ec18b5c28b99','Banyan','banyon','2024-09-02 23:27:36');
CREATE TABLE organization_roles (
  id text primary key not null,
  role_name text check( role_name in ('admin', 'editor', 'viewer') ) not null,
  organization_id text not null default '407a4662-8f72-4883-a87c-f6e3649b2b89',
  user_id text not null default '04e229c9-795e-4f3a-a79e-ec18b5c28b99',
  added_at datetime not null default current_timestamp,
  foreign key(organization_id) references organizations(id),
  foreign key(user_id) references users(id),
  unique(role_name, organization_id, user_id)
);
INSERT INTO organization_roles VALUES('0e8efe8b-5429-4a78-9e39-59b35aeee19b','editor','407a4662-8f72-4883-a87c-f6e3649b2b89','04e229c9-795e-4f3a-a79e-ec18b5c28b99','2024-09-02 23:27:36');
CREATE TABLE organization_categories (
  id primary key not null,
  organization_id text not null default '407a4662-8f72-4883-a87c-f6e3649b2b89',
  name text check( trim(name) != '' ) not null,
  added_at datetime not null default current_timestamp,
  foreign key(organization_id) references organizations(id),
  unique(organization_id, name)
);
INSERT INTO organization_categories VALUES('9f31bf67-29b6-43c9-8b4c-3bdb77e959a7','407a4662-8f72-4883-a87c-f6e3649b2b89','Unspecified','2024-09-02 23:27:36');
INSERT INTO organization_categories VALUES('f56be999-86d8-4394-a69c-4882e3bfad70','407a4662-8f72-4883-a87c-f6e3649b2b89','Programming language','2024-09-02 23:27:36');
CREATE TABLE organization_tracks (
  id text primary key not null,
  organization_id text not null default '407a4662-8f72-4883-a87c-f6e3649b2b89',
  category_id text not null,
  name text check( trim(name) != '' ) not null,
  added_at datetime not null default current_timestamp,
  foreign key(organization_id) references organizations(id),
  foreign key(category_id) references organization_categories(id),
  unique(organization_id, category_id, name)
);
INSERT INTO organization_tracks VALUES('e10fa49d-57a2-41a8-af68-7ea1b0b470ca','407a4662-8f72-4883-a87c-f6e3649b2b89','9f31bf67-29b6-43c9-8b4c-3bdb77e959a7','Unspecified','2024-09-02 23:27:36');
INSERT INTO organization_tracks VALUES('af3f8556-654a-45a7-9c16-cf745a0e0f50','407a4662-8f72-4883-a87c-f6e3649b2b89','f56be999-86d8-4394-a69c-4882e3bfad70','Rust','2024-09-02 23:27:36');
CREATE TABLE repos (
  id text primary key not null,
  organization_id text not null default '407a4662-8f72-4883-a87c-f6e3649b2b89',
  owner_id text not null default '04e229c9-795e-4f3a-a79e-ec18b5c28b99',
  name_slug text check(
    name_slug = lower(name_slug) and name_slug not like '% %'
  ) not null,
  summary text not null,
  added_at datetime not null default current_timestamp,
  foreign key(organization_id) references organizations(id),
  foreign key(owner_id) references users(id),
  unique(organization_id, name_slug)
);
INSERT INTO repos VALUES('bfeea3c3-1160-488f-aac7-16919b6da713','407a4662-8f72-4883-a87c-f6e3649b2b89','04e229c9-795e-4f3a-a79e-ec18b5c28b99','experiments','Experiments','2024-09-02 23:27:36');
CREATE TABLE task_versions (
  id number primary key not null,
  task_id text not null,
  parent_version_id text,
  document text not null,
  added_at datetime not null default current_timestamp,
  foreign key(task_id) references tasks(id),
  foreign key(parent_version_id) references task_versions(id)
);
CREATE TABLE tasks (
  id primary key not null,
  organization_id text not null default '407a4662-8f72-4883-a87c-f6e3649b2b89',
  repo_id text not null default 'bfeea3c3-1160-488f-aac7-16919b6da713',
  author_id text not null default '04e229c9-795e-4f3a-a79e-ec18b5c28b99',
  action text check(
    action in (
      'acquireSkill',
      'completeProblem',
      'completeQuestion',
      'completeQuestionSet'
    )
  ) not null,
  summary text not null,
  added_at datetime not null default current_timestamp,
  foreign key(author_id) references users(id),
  foreign key(repo_id) references repos(id),
  foreign key(organization_id) references organizations(id)
);
INSERT INTO tasks VALUES('5f10b96b-7032-481b-84de-fd1d37a33cde','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Measuring the height of a building using the properties of right triangles','2024-08-25 22:54:50');
INSERT INTO tasks VALUES('ef615296-bd68-4660-8ed8-f1056ce7c2bd','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','If you divide a circle into six equal segments, what is the angle of each segment in degrees?','2024-08-25 22:54:50');
INSERT INTO tasks VALUES('8c91f5b7-9cf8-4ce2-8626-6756b0d85d52','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','What is the diameter of a circle whose radius is 5cm?','2024-08-25 22:54:50');
INSERT INTO tasks VALUES('7de3e676-d23a-422c-8e9a-499398fb487e','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','What is the radius of a circle whose circumference is 20cm?','2024-08-25 22:54:50');
INSERT INTO tasks VALUES('b0120309-5a11-4015-8d32-583dbf73ac7e','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Which line in this diagram of a circle is the length of its radius?','2024-08-25 22:54:50');
INSERT INTO tasks VALUES('ad306d13-9ef4-4f7e-94f8-7660570edd44','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Which line in this diagram of a circle is the length of its diameter?','2024-08-25 22:54:50');
INSERT INTO tasks VALUES('bca284ca-3064-4bef-805c-c11a55a0ad93','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Which line in this diagram of a circle is the length of its circumference?','2024-08-25 22:54:50');
INSERT INTO tasks VALUES('2e959eb0-fb53-4684-bc7c-29ccb9d3e3a1','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Deriving a partial differential equation to model the amount of pollution in a tank of water','2024-08-25 22:54:50');
INSERT INTO tasks VALUES('62bcfc08-c98e-4e29-9720-0847f856517d','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Calculate the 2022 rent in euros of an apartment in Vienna that was 700 schillings per month in 1971','2024-08-25 22:54:50');
INSERT INTO tasks VALUES('ad6f42a7-45c2-4029-806f-5231cb3e9abb','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #1 from David Tolnay''s Rust Quiz','2024-08-25 22:54:51');
INSERT INTO tasks VALUES('eab3c420-aece-4a84-abdd-a398a438242c','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #2 from David Tolnay''s Rust Quiz','2024-08-25 22:54:52');
INSERT INTO tasks VALUES('f4e744ac-fc91-4527-bf41-0cb8077a1b5d','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #3 from David Tolnay''s Rust Quiz','2024-08-25 22:54:53');
INSERT INTO tasks VALUES('359a50c7-0ad5-424d-8cb1-6396a5f7ece9','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #4 from David Tolnay''s Rust Quiz','2024-08-25 22:57:43');
INSERT INTO tasks VALUES('d52fb8d8-acc6-4dd7-b724-b798abd52175','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #6 from David Tolnay''s Rust Quiz','2024-08-25 22:58:13');
INSERT INTO tasks VALUES('34062c38-e57e-4dac-b653-b695e85863b3','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #8 from David Tolnay''s Rust Quiz','2024-08-25 22:58:34');
INSERT INTO tasks VALUES('08bce113-d1b7-4c24-ba76-ce1a24613959','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz#9 from David Tolnay''s Rust Quiz','2024-08-25 22:58:55');
INSERT INTO tasks VALUES('3403caef-4fe4-4e6c-8bf2-28328ab3c86a','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #10 from David Tolnay''s Rust Quiz','2024-08-25 22:59:12');
INSERT INTO tasks VALUES('d04a9901-bbb3-461d-8976-eaa52704c64a','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #11 from David Tolnay''s Rust Quiz','2024-08-25 22:59:30');
INSERT INTO tasks VALUES('e0f53b73-0ae9-413b-bff3-884e73654960','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #12 from David Tolnay''s Rust Quiz','2024-08-25 22:59:47');
INSERT INTO tasks VALUES('a987600c-c2a9-4087-9eef-20d4cdb4f471','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #13 from David Tolnay''s Rust Quiz','2024-08-25 23:00:08');
INSERT INTO tasks VALUES('e0317968-b0bc-468f-86c0-4968b445aa23','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #14 from David Tolnay''s Rust Quiz','2024-08-25 23:00:25');
INSERT INTO tasks VALUES('ff2760b1-aeb3-46f4-a092-8cae0da9be31','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #15 from David Tolnay''s Rust Quiz','2024-08-25 23:00:50');
INSERT INTO tasks VALUES('328466c3-f22f-4ac5-baca-2f7089d4184a','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #16 from David Tolnay''s Rust Quiz','2024-08-25 23:03:16');
INSERT INTO tasks VALUES('4c09e3e6-ce11-443e-82f9-26579204c773','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #17 from David Tolnay''s Rust Quiz','2024-08-25 23:03:39');
INSERT INTO tasks VALUES('93a8dfbe-6fe0-4200-a2a1-9728c019938f','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #18 from David Tolnay''s Rust Quiz','2024-08-25 23:03:59');
INSERT INTO tasks VALUES('990534d5-beb7-478e-bd95-30462c460ac1','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #19 from David Tolnay''s Rust Quiz','2024-08-25 23:04:18');
INSERT INTO tasks VALUES('cc48c751-3aeb-433b-b88e-55191caa76a1','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #20 from David Tolnay''s Rust Quiz','2024-08-25 23:04:42');
INSERT INTO tasks VALUES('74c10a2d-f2a9-4734-a66e-1b3a351bb0ac','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #21 from David Tolnay''s Rust Quiz','2024-08-25 23:05:00');
INSERT INTO tasks VALUES('9b8c1918-95cb-4888-9a0e-f1f39c2367e9','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #22 from David Tolnay''s Rust Quiz','2024-08-25 23:05:18');
INSERT INTO tasks VALUES('5cfe07b1-4363-40da-898f-4eb192c305bb','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #23 from David Tolnay''s Rust Quiz','2024-08-25 23:05:43');
INSERT INTO tasks VALUES('9223e4e4-f0ef-434d-8e0b-74333c837d56','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #24 from David Tolnay''s Rust Quiz','2024-08-25 23:06:03');
INSERT INTO tasks VALUES('0a35c3ac-32a1-4173-9c0f-9334001805e5','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #25 from David Tolnay''s Rust Quiz','2024-08-25 23:06:21');
INSERT INTO tasks VALUES('9c607f1f-f6e2-4520-b282-4f5e4497d940','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #26 from David Tolnay''s Rust Quiz','2024-08-25 23:06:40');
INSERT INTO tasks VALUES('0f345bd0-24eb-473a-90d3-5060b68f8884','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #27 from David Tolnay''s Rust Quiz','2024-08-25 23:06:58');
INSERT INTO tasks VALUES('1f1bc291-feec-4baf-8af3-1308a18f6c29','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #28 from David Tolnay''s Rust Quiz','2024-08-25 23:07:20');
INSERT INTO tasks VALUES('5f1e64f0-8e2f-4226-a7bb-24366991a20b','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #29 from David Tolnay''s Rust Quiz','2024-08-25 23:07:38');
INSERT INTO tasks VALUES('28ea0c4a-5349-47dc-afe8-c4dab792e568','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #30 from David Tolnay''s Rust Quiz','2024-08-25 23:07:56');
INSERT INTO tasks VALUES('3cd82009-1c9e-4e37-a46c-b58ffcf3b83d','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #31 from David Tolnay''s Rust Quiz','2024-08-25 23:08:14');
INSERT INTO tasks VALUES('5b984244-6b8d-45c6-97a5-afde85d01cdf','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #32 from David Tolnay''s Rust Quiz','2024-08-25 23:08:35');
INSERT INTO tasks VALUES('ea9e8f26-bef5-48a9-bd69-58ca4b17c97f','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #33 from David Tolnay''s Rust Quiz','2024-08-25 23:08:52');
INSERT INTO tasks VALUES('19b83a23-8b2d-4596-a435-043483f37cc1','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #34 from David Tolnay''s Rust Quiz','2024-08-25 23:09:13');
INSERT INTO tasks VALUES('eefd649a-66ee-4a34-9fcc-61a05fc910b5','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #35 from David Tolnay''s Rust Quiz','2024-08-25 23:09:30');
INSERT INTO tasks VALUES('2c1c31c1-c8a6-4707-b4c7-211d911317df','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #36 from David Tolnay''s Rust Quiz','2024-08-25 23:09:52');
INSERT INTO tasks VALUES('a500f40e-3448-4fee-8de7-06979fd57c35','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','A challenging Rust problem that requires mastery of David Tolnay''s Rust Quiz to complete','2024-08-25 23:12:53');
INSERT INTO tasks VALUES('c21e18ae-951a-4d8f-984a-cff1f03a8906','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Computing the length of the opposite side of a right triangle from the length of the adjacent side and the angle between the adjacent side and the hypotenuse','2024-09-02 23:27:36');
INSERT INTO tasks VALUES('6253e17f-b44e-4d80-ac2a-db4474ca6cc8','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Measuring angles using degrees','2024-09-02 23:27:36');
INSERT INTO tasks VALUES('dc5b0bef-4472-43d9-9252-6de96b71b68c','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Subdividing circles into segments','2024-09-02 23:27:36');
INSERT INTO tasks VALUES('bb08e32d-5db5-49fc-97d1-9027bb2b6a29','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Measuring in centimeters','2024-09-02 23:27:36');
INSERT INTO tasks VALUES('752c7a54-d89c-4298-9203-ea73a0866790','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Computing the diameter of a circle from its radius','2024-09-02 23:27:36');
INSERT INTO tasks VALUES('d2d5b2bf-1c69-4879-a3f5-75ae65c484b7','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Computing the radius of a circle from its circumference','2024-09-02 23:27:36');
INSERT INTO tasks VALUES('a1e29ba4-e514-4968-94e0-4a4f73c75701','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Identifying the radius of a circle','2024-09-02 23:27:36');
INSERT INTO tasks VALUES('8c95f096-91aa-4d9e-a612-401d325becd4','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Identifying the diameter of a circle','2024-09-02 23:27:36');
INSERT INTO tasks VALUES('54209a1a-ae03-4ff5-aa67-072873577406','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Understanding the circumference of a circle','2024-09-02 23:27:36');
INSERT INTO tasks VALUES('5ec87192-2893-4981-9b1d-7456ae92af93','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Understanding the length of a line','2024-09-02 23:27:36');
INSERT INTO tasks VALUES('909052bb-8d7d-4b90-86f5-ccc443140a18','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Working with liters','2024-09-02 23:27:36');
INSERT INTO tasks VALUES('c7299bc0-8604-4469-bec7-c449ba1bf060','407a4662-8f72-4883-a87c-f6e3649b2b89','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Ability to complete David Tolnay''s Rust Quiz without mistakes','2024-09-02 23:27:36');
CREATE TABLE approaches (
  id text primary key,
  task_id text not null,
  summary text not null,
  unspecified boolean not null default 1,
  added_at datetime not null default current_timestamp,
  foreign key(task_id) references tasks(id)
);
INSERT INTO approaches VALUES('eed2ab67-c579-4997-838e-599f9f69a025','2e959eb0-fb53-4684-bc7c-29ccb9d3e3a1','Derivation of a partial equation to model the system',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('e785d88d-e55e-4901-88d5-ee0841ce7e13','5f10b96b-7032-481b-84de-fd1d37a33cde','Default',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('566ee9de-f11e-4aac-9850-ee94aa1abea6','7de3e676-d23a-422c-8e9a-499398fb487e','Default',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('c1f78392-d7a2-46b0-a40a-7292d3b8e4ea','8c91f5b7-9cf8-4ce2-8626-6756b0d85d52','Multiplying by two',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('fd6e4065-74ce-4b48-bd8f-dd8634fb5b35','ad306d13-9ef4-4f7e-94f8-7660570edd44','Default',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('b38930a3-9bdf-45d7-89a3-861d1b727f1c','b0120309-5a11-4015-8d32-583dbf73ac7e','Default',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('a410aad8-5d4f-477d-b90d-74b1fdc3a6bd','bca284ca-3064-4bef-805c-c11a55a0ad93','Default',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('d8e6714e-2788-4e53-8a55-9a7acb4b470b','ef615296-bd68-4660-8ed8-f1056ce7c2bd','Subdividing by thirds',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('6e4c7350-4d67-4293-94c3-d5431b019537','7de3e676-d23a-422c-8e9a-499398fb487e','Another approach',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('a1d0bcbe-f9bb-47cc-995c-cc069ab1f18a','7de3e676-d23a-422c-8e9a-499398fb487e','A third way to do this problem',1,'2024-09-02 23:27:36');
CREATE TABLE approach_prereqs (
  id text primary key not null,
  approach_id text not null,
  prereq_approach_id text not null,
  added_at datetime not null default current_timestamp,
  foreign key(approach_id) references approaches(id),
  foreign key(prereq_approach_id) references approaches(id),
  unique(approach_id, prereq_approach_id)
);
CREATE TABLE queues (
  id text primary key not null,
  user_id text not null default '04e229c9-795e-4f3a-a79e-ec18b5c28b99',
  strategy text check( strategy in ('spacedRepetitionV1', 'deterministic') ) not null default 'spacedRepetitionV1',
  cadence text check( cadence in ('minutes', 'hours', 'days') ) not null default 'days',
  summary text not null,
  target_approach_id text not null,
  added_at timestamp not null default current_timestamp,
  foreign key(target_approach_id) references approaches(id),
  foreign key(user_id) references users(id)
);
CREATE TABLE queue_tracks (
  queue_id text not null,
  organization_track_id text not null,
  primary key(queue_id, organization_track_id)
);
CREATE TABLE outcomes (
  id text primary key not null,
  queue_id text not null,
  user_id text not null,
  approach_id text not null,
  organization_track_id text not null,
  outcome string check(outcome in ('completed', 'needsRetry', 'tooHard')) not null,
  progress number not null default 0,
  added_at timestamp not null default current_timestamp,
  foreign key(organization_track_id) references organization_tracks(id),
  foreign key(queue_id) references queues(id),
  foreign key(approach_id) references approaches(id),
  foreign key(user_id) references users(id)
);
CREATE UNIQUE INDEX task_versions_uniq_idx on task_versions
  (task_id, ifnull(parent_version_id, 0));

insert into tasks (id, action, summary)
  values ('5bfdf4f7-c0bf-48eb-aa89-5643314738ec', 'completeProblem', 'Problem to be solved');

insert into approaches (id, task_id, summary, unspecified)
  values ('e1994385-5e8f-4651-a13b-429bad75bc54', '5bfdf4f7-c0bf-48eb-aa89-5643314738ec', 'Unspecified', true);

insert into queues (id, strategy, cadence, summary, target_approach_id)
  values ('2df309a7-8ece-4a14-a5f5-49699d2cba54', 'spacedRepetitionV1', 'minutes', 'A queue of test problems', 'e1994385-5e8f-4651-a13b-429bad75bc54');
