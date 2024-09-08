PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
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
CREATE TABLE repo_categories (
  id primary key not null,
  repo_id text not null default 'bfeea3c3-1160-488f-aac7-16919b6da713',
  name text check( trim(name) != '' ) not null,
  added_at datetime not null default current_timestamp,
  foreign key(repo_id) references repos(id),
  unique(repo_id, name)
);
INSERT INTO repo_categories VALUES('9f31bf67-29b6-43c9-8b4c-3bdb77e959a7','bfeea3c3-1160-488f-aac7-16919b6da713','Unspecified','2024-09-02 23:27:36');
INSERT INTO repo_categories VALUES('f56be999-86d8-4394-a69c-4882e3bfad70','bfeea3c3-1160-488f-aac7-16919b6da713','Programming languages','2024-09-02 23:27:36');
CREATE TABLE repo_tracks (
  id text primary key not null,
  repo_id text not null default 'bfeea3c3-1160-488f-aac7-16919b6da713',
  repo_category_id text not null,
  name text check( trim(name) != '' ) not null,
  added_at datetime not null default current_timestamp,
  foreign key(repo_id) references repos(id),
  foreign key(repo_category_id) references repo_categories(id),
  unique(repo_id, repo_category_id, name)
);
INSERT INTO repo_tracks VALUES('e10fa49d-57a2-41a8-af68-7ea1b0b470ca','bfeea3c3-1160-488f-aac7-16919b6da713','9f31bf67-29b6-43c9-8b4c-3bdb77e959a7','Unspecified','2024-09-02 23:27:36');
INSERT INTO repo_tracks VALUES('af3f8556-654a-45a7-9c16-cf745a0e0f50','bfeea3c3-1160-488f-aac7-16919b6da713','f56be999-86d8-4394-a69c-4882e3bfad70','Rust','2024-09-02 23:27:36');
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
  question_prompt text,
  question_url text,
  foreign key(author_id) references users(id),
  foreign key(repo_id) references repos(id)
);
INSERT INTO tasks VALUES('5f10b96b-7032-481b-84de-fd1d37a33cde','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Measuring the height of a building using the properties of right triangles','2024-08-25 22:54:50',NULL,NULL);
INSERT INTO tasks VALUES('ef615296-bd68-4660-8ed8-f1056ce7c2bd','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','If you divide a circle into six equal segments, what is the angle of each segment in degrees?','2024-08-25 22:54:50',NULL,NULL);
INSERT INTO tasks VALUES('8c91f5b7-9cf8-4ce2-8626-6756b0d85d52','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','What is the diameter of a circle whose radius is 5cm?','2024-08-25 22:54:50',NULL,NULL);
INSERT INTO tasks VALUES('7de3e676-d23a-422c-8e9a-499398fb487e','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','What is the radius of a circle whose circumference is 20cm?','2024-08-25 22:54:50',NULL,NULL);
INSERT INTO tasks VALUES('b0120309-5a11-4015-8d32-583dbf73ac7e','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Which line in this diagram of a circle is the length of its radius?','2024-08-25 22:54:50',NULL,NULL);
INSERT INTO tasks VALUES('ad306d13-9ef4-4f7e-94f8-7660570edd44','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Which line in this diagram of a circle is the length of its diameter?','2024-08-25 22:54:50',NULL,NULL);
INSERT INTO tasks VALUES('bca284ca-3064-4bef-805c-c11a55a0ad93','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Which line in this diagram of a circle is the length of its circumference?','2024-08-25 22:54:50',NULL,NULL);
INSERT INTO tasks VALUES('2e959eb0-fb53-4684-bc7c-29ccb9d3e3a1','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Deriving a partial differential equation to model the amount of pollution in a tank of water','2024-08-25 22:54:50',NULL,NULL);
INSERT INTO tasks VALUES('62bcfc08-c98e-4e29-9720-0847f856517d','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Calculate the 2022 rent in euros of an apartment in Vienna that was 700 schillings per month in 1971','2024-08-25 22:54:50',NULL,NULL);
INSERT INTO tasks VALUES('ad6f42a7-45c2-4029-806f-5231cb3e9abb','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #1 from David Tolnay''s Rust Quiz','2024-08-25 22:54:51',NULL,'https://dtolnay.github.io/rust-quiz/1');
INSERT INTO tasks VALUES('eab3c420-aece-4a84-abdd-a398a438242c','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #2 from David Tolnay''s Rust Quiz','2024-08-25 22:54:52',NULL,'https://dtolnay.github.io/rust-quiz/2');
INSERT INTO tasks VALUES('f4e744ac-fc91-4527-bf41-0cb8077a1b5d','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #3 from David Tolnay''s Rust Quiz','2024-08-25 22:54:53',NULL,'https://dtolnay.github.io/rust-quiz/3');
INSERT INTO tasks VALUES('359a50c7-0ad5-424d-8cb1-6396a5f7ece9','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #4 from David Tolnay''s Rust Quiz','2024-08-25 22:57:43',NULL,'https://dtolnay.github.io/rust-quiz/4');
INSERT INTO tasks VALUES('d52fb8d8-acc6-4dd7-b724-b798abd52175','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #6 from David Tolnay''s Rust Quiz','2024-08-25 22:58:13',NULL,'https://dtolnay.github.io/rust-quiz/6');
INSERT INTO tasks VALUES('34062c38-e57e-4dac-b653-b695e85863b3','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #8 from David Tolnay''s Rust Quiz','2024-08-25 22:58:34',NULL,'https://dtolnay.github.io/rust-quiz/8');
INSERT INTO tasks VALUES('08bce113-d1b7-4c24-ba76-ce1a24613959','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #9 from David Tolnay''s Rust Quiz','2024-08-25 22:58:55',NULL,'https://dtolnay.github.io/rust-quiz/9');
INSERT INTO tasks VALUES('3403caef-4fe4-4e6c-8bf2-28328ab3c86a','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #10 from David Tolnay''s Rust Quiz','2024-08-25 22:59:12',NULL,'https://dtolnay.github.io/rust-quiz/10');
INSERT INTO tasks VALUES('d04a9901-bbb3-461d-8976-eaa52704c64a','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #11 from David Tolnay''s Rust Quiz','2024-08-25 22:59:30',NULL,'https://dtolnay.github.io/rust-quiz/11');
INSERT INTO tasks VALUES('e0f53b73-0ae9-413b-bff3-884e73654960','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #12 from David Tolnay''s Rust Quiz','2024-08-25 22:59:47',NULL,'https://dtolnay.github.io/rust-quiz/12');
INSERT INTO tasks VALUES('a987600c-c2a9-4087-9eef-20d4cdb4f471','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #13 from David Tolnay''s Rust Quiz','2024-08-25 23:00:08',NULL,'https://dtolnay.github.io/rust-quiz/13');
INSERT INTO tasks VALUES('e0317968-b0bc-468f-86c0-4968b445aa23','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #14 from David Tolnay''s Rust Quiz','2024-08-25 23:00:25',NULL,'https://dtolnay.github.io/rust-quiz/14');
INSERT INTO tasks VALUES('ff2760b1-aeb3-46f4-a092-8cae0da9be31','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #15 from David Tolnay''s Rust Quiz','2024-08-25 23:00:50',NULL,'https://dtolnay.github.io/rust-quiz/15');
INSERT INTO tasks VALUES('328466c3-f22f-4ac5-baca-2f7089d4184a','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #16 from David Tolnay''s Rust Quiz','2024-08-25 23:03:16',NULL,'https://dtolnay.github.io/rust-quiz/16');
INSERT INTO tasks VALUES('4c09e3e6-ce11-443e-82f9-26579204c773','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #17 from David Tolnay''s Rust Quiz','2024-08-25 23:03:39',NULL,'https://dtolnay.github.io/rust-quiz/17');
INSERT INTO tasks VALUES('93a8dfbe-6fe0-4200-a2a1-9728c019938f','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #18 from David Tolnay''s Rust Quiz','2024-08-25 23:03:59',NULL,'https://dtolnay.github.io/rust-quiz/18');
INSERT INTO tasks VALUES('990534d5-beb7-478e-bd95-30462c460ac1','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #19 from David Tolnay''s Rust Quiz','2024-08-25 23:04:18',NULL,'https://dtolnay.github.io/rust-quiz/19');
INSERT INTO tasks VALUES('cc48c751-3aeb-433b-b88e-55191caa76a1','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #20 from David Tolnay''s Rust Quiz','2024-08-25 23:04:42',NULL,'https://dtolnay.github.io/rust-quiz/20');
INSERT INTO tasks VALUES('74c10a2d-f2a9-4734-a66e-1b3a351bb0ac','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #21 from David Tolnay''s Rust Quiz','2024-08-25 23:05:00',NULL,'https://dtolnay.github.io/rust-quiz/21');
INSERT INTO tasks VALUES('9b8c1918-95cb-4888-9a0e-f1f39c2367e9','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #22 from David Tolnay''s Rust Quiz','2024-08-25 23:05:18',NULL,'https://dtolnay.github.io/rust-quiz/22');
INSERT INTO tasks VALUES('5cfe07b1-4363-40da-898f-4eb192c305bb','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #23 from David Tolnay''s Rust Quiz','2024-08-25 23:05:43',NULL,'https://dtolnay.github.io/rust-quiz/23');
INSERT INTO tasks VALUES('9223e4e4-f0ef-434d-8e0b-74333c837d56','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #24 from David Tolnay''s Rust Quiz','2024-08-25 23:06:03',NULL,'https://dtolnay.github.io/rust-quiz/24');
INSERT INTO tasks VALUES('0a35c3ac-32a1-4173-9c0f-9334001805e5','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #25 from David Tolnay''s Rust Quiz','2024-08-25 23:06:21',NULL,'https://dtolnay.github.io/rust-quiz/25');
INSERT INTO tasks VALUES('9c607f1f-f6e2-4520-b282-4f5e4497d940','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #26 from David Tolnay''s Rust Quiz','2024-08-25 23:06:40',NULL,'https://dtolnay.github.io/rust-quiz/26');
INSERT INTO tasks VALUES('0f345bd0-24eb-473a-90d3-5060b68f8884','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #27 from David Tolnay''s Rust Quiz','2024-08-25 23:06:58',NULL,'https://dtolnay.github.io/rust-quiz/27');
INSERT INTO tasks VALUES('1f1bc291-feec-4baf-8af3-1308a18f6c29','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #28 from David Tolnay''s Rust Quiz','2024-08-25 23:07:20',NULL,'https://dtolnay.github.io/rust-quiz/28');
INSERT INTO tasks VALUES('5f1e64f0-8e2f-4226-a7bb-24366991a20b','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #29 from David Tolnay''s Rust Quiz','2024-08-25 23:07:38',NULL,'https://dtolnay.github.io/rust-quiz/29');
INSERT INTO tasks VALUES('28ea0c4a-5349-47dc-afe8-c4dab792e568','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #30 from David Tolnay''s Rust Quiz','2024-08-25 23:07:56',NULL,'https://dtolnay.github.io/rust-quiz/30');
INSERT INTO tasks VALUES('3cd82009-1c9e-4e37-a46c-b58ffcf3b83d','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #31 from David Tolnay''s Rust Quiz','2024-08-25 23:08:14',NULL,'https://dtolnay.github.io/rust-quiz/31');
INSERT INTO tasks VALUES('5b984244-6b8d-45c6-97a5-afde85d01cdf','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #32 from David Tolnay''s Rust Quiz','2024-08-25 23:08:35',NULL,'https://dtolnay.github.io/rust-quiz/32');
INSERT INTO tasks VALUES('ea9e8f26-bef5-48a9-bd69-58ca4b17c97f','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #33 from David Tolnay''s Rust Quiz','2024-08-25 23:08:52',NULL,'https://dtolnay.github.io/rust-quiz/33');
INSERT INTO tasks VALUES('19b83a23-8b2d-4596-a435-043483f37cc1','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #34 from David Tolnay''s Rust Quiz','2024-08-25 23:09:13',NULL,'https://dtolnay.github.io/rust-quiz/34');
INSERT INTO tasks VALUES('eefd649a-66ee-4a34-9fcc-61a05fc910b5','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #35 from David Tolnay''s Rust Quiz','2024-08-25 23:09:30',NULL,'https://dtolnay.github.io/rust-quiz/35');
INSERT INTO tasks VALUES('2c1c31c1-c8a6-4707-b4c7-211d911317df','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Rust Quiz #36 from David Tolnay''s Rust Quiz','2024-08-25 23:09:52',NULL,'https://dtolnay.github.io/rust-quiz/36');
INSERT INTO tasks VALUES('a500f40e-3448-4fee-8de7-06979fd57c35','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','A challenging Rust problem that requires mastery of David Tolnay''s Rust Quiz to complete','2024-08-25 23:12:53',NULL,NULL);
INSERT INTO tasks VALUES('c21e18ae-951a-4d8f-984a-cff1f03a8906','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Computing the length of the opposite side of a right triangle from the length of the adjacent side and the angle between the adjacent side and the hypotenuse','2024-09-02 23:27:36',NULL,NULL);
INSERT INTO tasks VALUES('6253e17f-b44e-4d80-ac2a-db4474ca6cc8','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Measuring angles using degrees','2024-09-02 23:27:36',NULL,NULL);
INSERT INTO tasks VALUES('dc5b0bef-4472-43d9-9252-6de96b71b68c','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Subdividing circles into segments','2024-09-02 23:27:36',NULL,NULL);
INSERT INTO tasks VALUES('bb08e32d-5db5-49fc-97d1-9027bb2b6a29','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Measuring in centimeters','2024-09-02 23:27:36',NULL,NULL);
INSERT INTO tasks VALUES('752c7a54-d89c-4298-9203-ea73a0866790','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Computing the diameter of a circle from its radius','2024-09-02 23:27:36',NULL,NULL);
INSERT INTO tasks VALUES('d2d5b2bf-1c69-4879-a3f5-75ae65c484b7','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Computing the radius of a circle from its circumference','2024-09-02 23:27:36',NULL,NULL);
INSERT INTO tasks VALUES('a1e29ba4-e514-4968-94e0-4a4f73c75701','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Identifying the radius of a circle','2024-09-02 23:27:36',NULL,NULL);
INSERT INTO tasks VALUES('8c95f096-91aa-4d9e-a612-401d325becd4','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Identifying the diameter of a circle','2024-09-02 23:27:36',NULL,NULL);
INSERT INTO tasks VALUES('54209a1a-ae03-4ff5-aa67-072873577406','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Understanding the circumference of a circle','2024-09-02 23:27:36',NULL,NULL);
INSERT INTO tasks VALUES('5ec87192-2893-4981-9b1d-7456ae92af93','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Understanding the length of a line','2024-09-02 23:27:36',NULL,NULL);
INSERT INTO tasks VALUES('909052bb-8d7d-4b90-86f5-ccc443140a18','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Working with liters','2024-09-02 23:27:36',NULL,NULL);
INSERT INTO tasks VALUES('c7299bc0-8604-4469-bec7-c449ba1bf060','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireSkill','Ability to complete David Tolnay''s Rust Quiz without mistakes','2024-09-02 23:27:36',NULL,NULL);
INSERT INTO tasks VALUES('5bfdf4f7-c0bf-48eb-aa89-5643314738ec','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Problem to be solved','2024-09-05 00:01:53',NULL,NULL);
CREATE TABLE approaches (
  id text primary key,
  task_id text not null,
  summary text not null,
  unspecified boolean not null default 1,
  added_at datetime not null default current_timestamp,
  foreign key(task_id) references tasks(id)
);
INSERT INTO approaches VALUES('eed2ab67-c579-4997-838e-599f9f69a025','2e959eb0-fb53-4684-bc7c-29ccb9d3e3a1','Derivation of a partial equation to model the system',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('e785d88d-e55e-4901-88d5-ee0841ce7e13','5f10b96b-7032-481b-84de-fd1d37a33cde','Unspecified',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('566ee9de-f11e-4aac-9850-ee94aa1abea6','7de3e676-d23a-422c-8e9a-499398fb487e','Unspecified',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('c1f78392-d7a2-46b0-a40a-7292d3b8e4ea','8c91f5b7-9cf8-4ce2-8626-6756b0d85d52','Multiplying by two',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('fd6e4065-74ce-4b48-bd8f-dd8634fb5b35','ad306d13-9ef4-4f7e-94f8-7660570edd44','Unspecified',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('b38930a3-9bdf-45d7-89a3-861d1b727f1c','b0120309-5a11-4015-8d32-583dbf73ac7e','Unspecified',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('a410aad8-5d4f-477d-b90d-74b1fdc3a6bd','bca284ca-3064-4bef-805c-c11a55a0ad93','Unspecified',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('d8e6714e-2788-4e53-8a55-9a7acb4b470b','ef615296-bd68-4660-8ed8-f1056ce7c2bd','Subdividing by thirds',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('6e4c7350-4d67-4293-94c3-d5431b019537','7de3e676-d23a-422c-8e9a-499398fb487e','Another approach',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('a1d0bcbe-f9bb-47cc-995c-cc069ab1f18a','7de3e676-d23a-422c-8e9a-499398fb487e','A third way to do this problem',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('81359cd2-ec5f-498f-b9c4-281a1d034e59','c7299bc0-8604-4469-bec7-c449ba1bf060','Unspecified',1,'2024-09-02 23:27:36');
INSERT INTO approaches VALUES('e1994385-5e8f-4651-a13b-429bad75bc54','5bfdf4f7-c0bf-48eb-aa89-5643314738ec','Unspecified',1,'2024-09-05 00:01:53');
INSERT INTO approaches VALUES('9cda4f06-c7de-47b0-928a-4cd76c936723','08bce113-d1b7-4c24-ba76-ce1a24613959','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('49e75eec-d95e-4e08-a69c-9d39e5598431','0a35c3ac-32a1-4173-9c0f-9334001805e5','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('9a8eafd6-cc55-4dfb-932e-75728881fc73','0f345bd0-24eb-473a-90d3-5060b68f8884','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('4fcc5aea-b0c3-441d-8c09-07053fb6679c','19b83a23-8b2d-4596-a435-043483f37cc1','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('ef3741d5-fe61-4b4c-bb02-796808eb2f42','1f1bc291-feec-4baf-8af3-1308a18f6c29','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('287dec24-33f8-418a-a91d-aa28609d2596','28ea0c4a-5349-47dc-afe8-c4dab792e568','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('0175e72c-7fe6-463d-ba23-27aafd5c4404','2c1c31c1-c8a6-4707-b4c7-211d911317df','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('aff87c21-5fbf-4cac-b0ac-2bca763e8df1','2e959eb0-fb53-4684-bc7c-29ccb9d3e3a1','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('39995993-b784-47f3-994f-ac9b5110ee9a','328466c3-f22f-4ac5-baca-2f7089d4184a','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('3a8c4401-4ef4-48d6-b192-99ad9cd5ea37','3403caef-4fe4-4e6c-8bf2-28328ab3c86a','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('8e43c714-33a9-4768-b0fa-f6839abfe27c','34062c38-e57e-4dac-b653-b695e85863b3','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('76a4a4b9-81ad-4980-841a-bff4f8e4d061','359a50c7-0ad5-424d-8cb1-6396a5f7ece9','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('9385f74c-1116-4ba4-87da-7691b3244181','3cd82009-1c9e-4e37-a46c-b58ffcf3b83d','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('3b4ac24a-df7e-4299-be5f-d15ab12a3533','4c09e3e6-ce11-443e-82f9-26579204c773','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('17ff50c6-dee1-4796-a414-ac6cc8580676','54209a1a-ae03-4ff5-aa67-072873577406','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('94f32ace-6458-4f44-aa65-3ee71c7f5869','5b984244-6b8d-45c6-97a5-afde85d01cdf','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('ab30df92-238d-4686-9857-7c00c70dbb15','5bfdf4f7-c0bf-48eb-aa89-5643314738ec','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('9932566a-0717-4759-bf96-d3f5b1c72cb9','5cfe07b1-4363-40da-898f-4eb192c305bb','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('d167f33f-6689-40a1-bbde-c9ff64b1a0ba','5ec87192-2893-4981-9b1d-7456ae92af93','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('04189f25-8ab5-46df-8633-07a13fc1c60d','5f10b96b-7032-481b-84de-fd1d37a33cde','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('8803f7fa-49a5-4dff-8fd3-27b5c7fbba14','5f1e64f0-8e2f-4226-a7bb-24366991a20b','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('3b1920f3-37d9-4f28-8209-795822e6724f','6253e17f-b44e-4d80-ac2a-db4474ca6cc8','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('dcc7a9cb-1171-4bfd-95dd-a3c15090afa0','62bcfc08-c98e-4e29-9720-0847f856517d','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('d27cd9e8-1bab-42de-a903-48317de1fec6','74c10a2d-f2a9-4734-a66e-1b3a351bb0ac','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('ed8b7bb7-54c6-4e6a-9806-2c90bd9f80eb','752c7a54-d89c-4298-9203-ea73a0866790','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('277405dd-20d7-4394-89bd-a51540f63c16','7de3e676-d23a-422c-8e9a-499398fb487e','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('4d2411c5-65af-4e5f-8bce-bcdd8f0d9b4a','8c91f5b7-9cf8-4ce2-8626-6756b0d85d52','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('3f64e19d-2f6d-45f3-8b28-dff63694c436','8c95f096-91aa-4d9e-a612-401d325becd4','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('398e081c-810a-4380-8f51-77df140f034f','909052bb-8d7d-4b90-86f5-ccc443140a18','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('a7a51b1b-0e38-4cdf-a8c9-9dd710d2549a','9223e4e4-f0ef-434d-8e0b-74333c837d56','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('3caeb4c7-a570-498a-a413-23e216dc426c','93a8dfbe-6fe0-4200-a2a1-9728c019938f','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('dc4d9fe1-e701-4484-9a80-46445ac07d7b','990534d5-beb7-478e-bd95-30462c460ac1','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('77c5f1b5-8604-407b-a696-9dde3b7e710a','9b8c1918-95cb-4888-9a0e-f1f39c2367e9','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('f4766946-df88-41cf-8ddd-e52c0d739667','9c607f1f-f6e2-4520-b282-4f5e4497d940','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('2ae2be7a-2eb3-4471-bc98-ea8f9d6a9e8a','a1e29ba4-e514-4968-94e0-4a4f73c75701','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('cee76fa8-849e-4403-ba86-4819b27d1491','a500f40e-3448-4fee-8de7-06979fd57c35','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('a0783fbf-a2b2-4dbe-b6b6-bbe5baf885db','a987600c-c2a9-4087-9eef-20d4cdb4f471','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('a8e695e7-3baf-4ea5-8272-11e41985c189','ad306d13-9ef4-4f7e-94f8-7660570edd44','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('b5f55bb7-8dd9-4a64-bda4-11df290902b2','ad6f42a7-45c2-4029-806f-5231cb3e9abb','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('afae3575-cc5d-4a36-98b6-ea4ad277c210','b0120309-5a11-4015-8d32-583dbf73ac7e','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('9cc65905-0cef-4b6c-8f19-fed301c9b4ae','bb08e32d-5db5-49fc-97d1-9027bb2b6a29','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('ed6e621f-25f1-476d-979e-9f31e034389b','bca284ca-3064-4bef-805c-c11a55a0ad93','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('7fa98377-a844-41dc-8fa5-6a40724a5f97','c21e18ae-951a-4d8f-984a-cff1f03a8906','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('6348e526-30fd-49ce-95d5-bef9a49ecea8','cc48c751-3aeb-433b-b88e-55191caa76a1','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('3d608cc5-e48f-4c1a-93a9-b07b85018a95','d04a9901-bbb3-461d-8976-eaa52704c64a','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('38941b9c-9531-4a41-a312-d7ffb4615cba','d2d5b2bf-1c69-4879-a3f5-75ae65c484b7','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('e9b8f589-6b1b-4c05-b243-b202289a5891','d52fb8d8-acc6-4dd7-b724-b798abd52175','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('9b8cb3f2-91fd-4f4b-acb2-5cec3ac8aa54','dc5b0bef-4472-43d9-9252-6de96b71b68c','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('4e927d2d-650a-40ea-bdd2-935fe131aacf','e0317968-b0bc-468f-86c0-4968b445aa23','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('5131162e-a407-476d-855c-1779b0bbc851','e0f53b73-0ae9-413b-bff3-884e73654960','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('063db326-e121-4dbd-8228-addac32f512c','ea9e8f26-bef5-48a9-bd69-58ca4b17c97f','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('d0639627-725e-4157-9ee4-80ec0028fe2f','eab3c420-aece-4a84-abdd-a398a438242c','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('812a4352-66c5-4870-8940-f439b70bcc0f','eefd649a-66ee-4a34-9fcc-61a05fc910b5','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('5e5fa30f-abe6-4c31-8a03-1d09395b77da','ef615296-bd68-4660-8ed8-f1056ce7c2bd','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('2068cd5c-c8ec-4d8b-acc1-fa3837954bbe','f4e744ac-fc91-4527-bf41-0cb8077a1b5d','Unspecified',1,'2024-09-05 00:39:56');
INSERT INTO approaches VALUES('bfef8ce1-88bc-403b-81e7-21863f1d2e61','ff2760b1-aeb3-46f4-a092-8cae0da9be31','Unspecified',1,'2024-09-05 00:39:56');
CREATE TABLE approach_prereqs (
  id text primary key not null,
  approach_id text not null,
  prereq_approach_id text not null,
  added_at datetime not null default current_timestamp,
  foreign key(approach_id) references approaches(id),
  foreign key(prereq_approach_id) references approaches(id),
  unique(approach_id, prereq_approach_id)
);
INSERT INTO approach_prereqs VALUES('ce9493a0-1cc4-406a-8eb4-93ff5fdfdfdb','81359cd2-ec5f-498f-b9c4-281a1d034e59','0175e72c-7fe6-463d-ba23-27aafd5c4404','2024-09-06 00:57:34');
INSERT INTO approach_prereqs VALUES('f94769f0-3fc6-4b8f-ac7d-e6ccc84e6281','81359cd2-ec5f-498f-b9c4-281a1d034e59','812a4352-66c5-4870-8940-f439b70bcc0f','2024-09-06 01:35:01');
INSERT INTO approach_prereqs VALUES('15d56d2f-0498-4141-97cc-43c6e1d380d5','81359cd2-ec5f-498f-b9c4-281a1d034e59','4fcc5aea-b0c3-441d-8c09-07053fb6679c','2024-09-06 02:25:38');
INSERT INTO approach_prereqs VALUES('bac21f77-3382-43ea-b8dc-459f442e0d2c','81359cd2-ec5f-498f-b9c4-281a1d034e59','063db326-e121-4dbd-8228-addac32f512c','2024-09-06 02:27:06');
INSERT INTO approach_prereqs VALUES('3204cd8d-53ed-46ef-99fd-f883878f11de','81359cd2-ec5f-498f-b9c4-281a1d034e59','94f32ace-6458-4f44-aa65-3ee71c7f5869','2024-09-06 02:28:56');
INSERT INTO approach_prereqs VALUES('792ef5b8-e058-4e5f-9c33-f83d3d46ba7a','81359cd2-ec5f-498f-b9c4-281a1d034e59','9385f74c-1116-4ba4-87da-7691b3244181','2024-09-06 03:20:39');
INSERT INTO approach_prereqs VALUES('281af862-418a-435c-ad8f-eb79a09b838c','81359cd2-ec5f-498f-b9c4-281a1d034e59','287dec24-33f8-418a-a91d-aa28609d2596','2024-09-06 03:21:14');
INSERT INTO approach_prereqs VALUES('43c3cad5-68f2-4f43-adee-757cccde72e4','81359cd2-ec5f-498f-b9c4-281a1d034e59','8803f7fa-49a5-4dff-8fd3-27b5c7fbba14','2024-09-06 03:21:19');
INSERT INTO approach_prereqs VALUES('1f2d747b-ba37-4f18-a421-be24f60ee0d7','81359cd2-ec5f-498f-b9c4-281a1d034e59','ef3741d5-fe61-4b4c-bb02-796808eb2f42','2024-09-06 03:21:23');
INSERT INTO approach_prereqs VALUES('382f4dc4-e6bd-4859-a19c-39324b198fcd','81359cd2-ec5f-498f-b9c4-281a1d034e59','9a8eafd6-cc55-4dfb-932e-75728881fc73','2024-09-06 03:21:27');
INSERT INTO approach_prereqs VALUES('ce0b48fb-0da0-4618-94fa-869aeee8382e','81359cd2-ec5f-498f-b9c4-281a1d034e59','f4766946-df88-41cf-8ddd-e52c0d739667','2024-09-06 03:21:31');
INSERT INTO approach_prereqs VALUES('6c5e1ce4-401e-47e9-a1ac-7e4810a4f0c8','81359cd2-ec5f-498f-b9c4-281a1d034e59','49e75eec-d95e-4e08-a69c-9d39e5598431','2024-09-06 03:21:38');
INSERT INTO approach_prereqs VALUES('ebb76d80-9a25-4091-8a4c-d2f7635676ea','81359cd2-ec5f-498f-b9c4-281a1d034e59','a7a51b1b-0e38-4cdf-a8c9-9dd710d2549a','2024-09-06 03:21:40');
INSERT INTO approach_prereqs VALUES('e3190ee5-6fac-4e77-8126-6a5190a24ec6','81359cd2-ec5f-498f-b9c4-281a1d034e59','9932566a-0717-4759-bf96-d3f5b1c72cb9','2024-09-06 03:21:43');
INSERT INTO approach_prereqs VALUES('4db91ca8-b529-4e78-82d9-4360775c9f59','81359cd2-ec5f-498f-b9c4-281a1d034e59','77c5f1b5-8604-407b-a696-9dde3b7e710a','2024-09-06 03:21:46');
INSERT INTO approach_prereqs VALUES('cf4a8741-7226-48bf-bc92-682bb1ad59c8','81359cd2-ec5f-498f-b9c4-281a1d034e59','d27cd9e8-1bab-42de-a903-48317de1fec6','2024-09-06 03:21:49');
INSERT INTO approach_prereqs VALUES('7144d05e-4baf-45d1-81e5-3287902f2edc','81359cd2-ec5f-498f-b9c4-281a1d034e59','6348e526-30fd-49ce-95d5-bef9a49ecea8','2024-09-06 03:21:53');
INSERT INTO approach_prereqs VALUES('6ca275ef-cfd4-4609-83cc-516220600cdb','81359cd2-ec5f-498f-b9c4-281a1d034e59','dc4d9fe1-e701-4484-9a80-46445ac07d7b','2024-09-06 03:21:56');
INSERT INTO approach_prereqs VALUES('65deff03-5a60-4800-9c90-b664895d68ed','81359cd2-ec5f-498f-b9c4-281a1d034e59','3caeb4c7-a570-498a-a413-23e216dc426c','2024-09-06 03:22:00');
INSERT INTO approach_prereqs VALUES('30c4d068-f2d8-43fa-8093-034ae03abce4','81359cd2-ec5f-498f-b9c4-281a1d034e59','3b4ac24a-df7e-4299-be5f-d15ab12a3533','2024-09-06 03:22:03');
INSERT INTO approach_prereqs VALUES('a0755d0f-a87a-4144-918a-a9bb8b941fdf','81359cd2-ec5f-498f-b9c4-281a1d034e59','39995993-b784-47f3-994f-ac9b5110ee9a','2024-09-06 03:22:08');
INSERT INTO approach_prereqs VALUES('455f8859-ef3c-49db-85d8-02d615eb606b','81359cd2-ec5f-498f-b9c4-281a1d034e59','bfef8ce1-88bc-403b-81e7-21863f1d2e61','2024-09-06 03:22:10');
INSERT INTO approach_prereqs VALUES('c61f11b5-c78c-4a3c-bbcf-39c643eb7a6e','81359cd2-ec5f-498f-b9c4-281a1d034e59','4e927d2d-650a-40ea-bdd2-935fe131aacf','2024-09-06 03:22:14');
INSERT INTO approach_prereqs VALUES('bc4efbc2-a150-45d3-80ab-f10ed7aa53bd','81359cd2-ec5f-498f-b9c4-281a1d034e59','a0783fbf-a2b2-4dbe-b6b6-bbe5baf885db','2024-09-06 03:22:16');
INSERT INTO approach_prereqs VALUES('f8302409-344a-49cf-a55d-a96e370d915a','81359cd2-ec5f-498f-b9c4-281a1d034e59','5131162e-a407-476d-855c-1779b0bbc851','2024-09-06 03:22:19');
INSERT INTO approach_prereqs VALUES('bd14b679-5cfe-4d28-b1ad-4c344b3c0340','81359cd2-ec5f-498f-b9c4-281a1d034e59','3d608cc5-e48f-4c1a-93a9-b07b85018a95','2024-09-06 03:22:22');
INSERT INTO approach_prereqs VALUES('1ef4c70c-50b3-4cfb-ab84-1041c42004d7','81359cd2-ec5f-498f-b9c4-281a1d034e59','3a8c4401-4ef4-48d6-b192-99ad9cd5ea37','2024-09-06 03:22:25');
INSERT INTO approach_prereqs VALUES('cb8a6168-d7ea-4db1-8b6a-e8f372369486','81359cd2-ec5f-498f-b9c4-281a1d034e59','9cda4f06-c7de-47b0-928a-4cd76c936723','2024-09-06 03:22:30');
INSERT INTO approach_prereqs VALUES('cff893da-fbfe-4803-8869-3d01087ce101','81359cd2-ec5f-498f-b9c4-281a1d034e59','8e43c714-33a9-4768-b0fa-f6839abfe27c','2024-09-06 03:22:33');
INSERT INTO approach_prereqs VALUES('e5578182-7279-431b-88e4-fd2081b1277f','81359cd2-ec5f-498f-b9c4-281a1d034e59','e9b8f589-6b1b-4c05-b243-b202289a5891','2024-09-06 03:22:39');
INSERT INTO approach_prereqs VALUES('f1890ae5-bee1-4d7c-b6f4-a2efd6649d44','81359cd2-ec5f-498f-b9c4-281a1d034e59','76a4a4b9-81ad-4980-841a-bff4f8e4d061','2024-09-06 03:22:49');
INSERT INTO approach_prereqs VALUES('0b806a09-513f-4393-b71d-1a76c4a44a45','81359cd2-ec5f-498f-b9c4-281a1d034e59','2068cd5c-c8ec-4d8b-acc1-fa3837954bbe','2024-09-06 03:22:51');
INSERT INTO approach_prereqs VALUES('55d17876-4439-42e7-a6dd-5b44cce74250','81359cd2-ec5f-498f-b9c4-281a1d034e59','d0639627-725e-4157-9ee4-80ec0028fe2f','2024-09-06 03:22:55');
INSERT INTO approach_prereqs VALUES('01536e74-83be-4b23-b36c-bc6f6565fc39','81359cd2-ec5f-498f-b9c4-281a1d034e59','b5f55bb7-8dd9-4a64-bda4-11df290902b2','2024-09-06 03:22:57');
CREATE TABLE queues (
  id text primary key not null,
  user_id text not null default '04e229c9-795e-4f3a-a79e-ec18b5c28b99',
  -- repo_id text not null default 'bfeea3c3-1160-488f-aac7-16919b6da713',
  strategy text check( strategy in ('spacedRepetitionV1', 'deterministic') ) not null default 'spacedRepetitionV1',
  cadence text check( cadence in ('minutes', 'hours', 'days') ) not null default 'days',
  summary text not null,
  target_approach_id text not null,
  added_at timestamp not null default current_timestamp,
  foreign key(target_approach_id) references approaches(id),
  foreign key(user_id) references users(id)
);
INSERT INTO queues VALUES('34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','spacedRepetitionV1','hours','David Tolnay''s Rust quiz','81359cd2-ec5f-498f-b9c4-281a1d034e59','2024-09-05 00:14:05');
CREATE TABLE queue_tracks (
  id primary key not null,
  queue_id text not null,
  repo_category_id text not null,
  repo_track_id text not null,
  added_at timestamp not null default current_timestamp,
  foreign key(queue_id) references queues(id),
  foreign key(repo_category_id) references repo_categories(id),
  foreign key(repo_track_id) references repo_tracks(id),
  -- If we allow more than one track per category, we'd need to cover a cross product of
  -- tasks x (category, selected tracks). E.g., we might need to show the same problem for
  -- both Rust and C++, or allow gaps in coverage.  Let's keep things simple by limiting ourselves
  -- to one track per category.
  unique(queue_id, repo_category_id)
);
INSERT INTO queue_tracks VALUES('302c69da-2154-466a-ab39-a8a81d5ca7f8','34b1de9d-ac94-433c-8369-0e121e97af43','f56be999-86d8-4394-a69c-4882e3bfad70','af3f8556-654a-45a7-9c16-cf745a0e0f50','2024-09-08 00:16:33');
INSERT INTO queue_tracks VALUES('6a4511cf-4002-4f27-9054-253bc85c0e8c','34b1de9d-ac94-433c-8369-0e121e97af43','9f31bf67-29b6-43c9-8b4c-3bdb77e959a7','e10fa49d-57a2-41a8-af68-7ea1b0b470ca','2024-09-08 00:58:02');
CREATE TABLE outcomes (
  id text primary key not null,
  queue_id text not null,
  user_id text not null,
  approach_id text not null,
  repo_track_id text not null,
  outcome string check(outcome in ('completed', 'needsRetry', 'tooHard')) not null,
  progress number not null default 0,
  added_at timestamp not null default current_timestamp,
  foreign key(repo_track_id) references repo_tracks(id),
  foreign key(queue_id) references queues(id),
  foreign key(approach_id) references approaches(id),
  foreign key(user_id) references users(id)
);
INSERT INTO outcomes VALUES('5f3bc9c6-49fb-40fb-abbc-da0898f5ae4b','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','0175e72c-7fe6-463d-ba23-27aafd5c4404','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T01:03:45.299487685+00:00');
INSERT INTO outcomes VALUES('88fc9253-ce69-4789-894c-b5348d75cb16','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','0175e72c-7fe6-463d-ba23-27aafd5c4404','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T04:00:54.534377837+00:00');
INSERT INTO outcomes VALUES('23a4260f-f7fd-4e98-860c-ae230902728a','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','063db326-e121-4dbd-8228-addac32f512c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:06:08.863541843+00:00');
INSERT INTO outcomes VALUES('d5d5d257-6d62-4717-9906-63e8d11ecea9','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','2068cd5c-c8ec-4d8b-acc1-fa3837954bbe','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:06:25.481767832+00:00');
INSERT INTO outcomes VALUES('5954db18-b566-4b7e-8f3f-4fa0fe449a79','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','287dec24-33f8-418a-a91d-aa28609d2596','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:06:44.405074903+00:00');
INSERT INTO outcomes VALUES('62201c4e-4ad3-4e98-b0c3-301310eae9f5','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','39995993-b784-47f3-994f-ac9b5110ee9a','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:07:08.055177418+00:00');
INSERT INTO outcomes VALUES('6f36290c-91fb-4f3e-811c-bc720853715b','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3a8c4401-4ef4-48d6-b192-99ad9cd5ea37','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:11:16.626805667+00:00');
INSERT INTO outcomes VALUES('3221ee5c-cd5a-443a-8044-c8b5124a4212','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3b4ac24a-df7e-4299-be5f-d15ab12a3533','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:11:26.544690829+00:00');
INSERT INTO outcomes VALUES('190e1bfd-41d5-4922-8e2b-847103616aa8','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3caeb4c7-a570-498a-a413-23e216dc426c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:11:46.956869368+00:00');
INSERT INTO outcomes VALUES('d59b5969-2e92-4a2a-845b-75b701c30901','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3d608cc5-e48f-4c1a-93a9-b07b85018a95','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:12:10.251209832+00:00');
INSERT INTO outcomes VALUES('726f8322-9e26-4aeb-a7d2-b5e90b09d706','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','49e75eec-d95e-4e08-a69c-9d39e5598431','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:12:32.832054236+00:00');
INSERT INTO outcomes VALUES('43aa873d-ac96-467d-837b-302c50336354','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','4e927d2d-650a-40ea-bdd2-935fe131aacf','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:13:01.770471600+00:00');
INSERT INTO outcomes VALUES('d9777845-9644-434a-9a06-16b8d3567d4a','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','4fcc5aea-b0c3-441d-8c09-07053fb6679c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:13:38.396109096+00:00');
INSERT INTO outcomes VALUES('30b5a521-368f-40be-8f8d-80744e35bb4d','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','5131162e-a407-476d-855c-1779b0bbc851','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:14:17.206850446+00:00');
INSERT INTO outcomes VALUES('4be4e57f-6055-4e57-ac90-de58478e352a','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','6348e526-30fd-49ce-95d5-bef9a49ecea8','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:14:35.368503167+00:00');
INSERT INTO outcomes VALUES('1d66ea6a-2c7d-472f-82cb-4c776cbd32e3','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','76a4a4b9-81ad-4980-841a-bff4f8e4d061','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:14:59.314043638+00:00');
INSERT INTO outcomes VALUES('40f79346-14b4-433f-8944-bb9dd04c148a','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','77c5f1b5-8604-407b-a696-9dde3b7e710a','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:15:13.212140836+00:00');
INSERT INTO outcomes VALUES('5e5f831b-3dfa-4555-9754-714477791f27','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','812a4352-66c5-4870-8940-f439b70bcc0f','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:15:39.221603868+00:00');
INSERT INTO outcomes VALUES('b41bbfba-99c8-42f0-8251-c73c2812c920','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','8803f7fa-49a5-4dff-8fd3-27b5c7fbba14','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:16:11.484242613+00:00');
INSERT INTO outcomes VALUES('32dd399b-829d-4f0e-a33b-18ad8d0a1099','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','8e43c714-33a9-4768-b0fa-f6839abfe27c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:16:28.782414675+00:00');
INSERT INTO outcomes VALUES('c8050f34-6591-46eb-a1c4-22ade6d1b510','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9385f74c-1116-4ba4-87da-7691b3244181','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:16:51.913187238+00:00');
INSERT INTO outcomes VALUES('18c8bdcd-d40a-402a-825b-d3d6ceefc2bf','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','94f32ace-6458-4f44-aa65-3ee71c7f5869','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:17:03.615267371+00:00');
INSERT INTO outcomes VALUES('5187407b-cbe3-440b-8dc3-eda6be1111c1','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9932566a-0717-4759-bf96-d3f5b1c72cb9','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:18:23.002408036+00:00');
INSERT INTO outcomes VALUES('d77589c3-0ee0-42e6-b135-2f66bef59c82','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9a8eafd6-cc55-4dfb-932e-75728881fc73','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:18:37.733667903+00:00');
INSERT INTO outcomes VALUES('df726cc5-cb01-4421-8c54-b056cd2c6fe1','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9cda4f06-c7de-47b0-928a-4cd76c936723','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:19:09.544874140+00:00');
INSERT INTO outcomes VALUES('37c7b1e2-caf9-40b0-a496-be6baa6e19f9','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','a0783fbf-a2b2-4dbe-b6b6-bbe5baf885db','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:19:53.190038209+00:00');
INSERT INTO outcomes VALUES('954a11e8-1081-422a-9b40-d0cf026708d9','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','a7a51b1b-0e38-4cdf-a8c9-9dd710d2549a','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:20:16.890766476+00:00');
INSERT INTO outcomes VALUES('4838b0f1-df9a-4527-b7f6-5418877cff07','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','b5f55bb7-8dd9-4a64-bda4-11df290902b2','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:20:27.723827787+00:00');
INSERT INTO outcomes VALUES('8d3cb5f1-4407-4c8b-95b9-de4e0e060144','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','bfef8ce1-88bc-403b-81e7-21863f1d2e61','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:21:08.971996385+00:00');
INSERT INTO outcomes VALUES('844a1e1c-a8de-4a25-a4ab-32b9a8de4b7f','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','d0639627-725e-4157-9ee4-80ec0028fe2f','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:21:27.875793487+00:00');
INSERT INTO outcomes VALUES('8378945e-7bf4-4f24-bd85-0988da293722','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','d27cd9e8-1bab-42de-a903-48317de1fec6','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:22:11.226371620+00:00');
INSERT INTO outcomes VALUES('657ce70e-14a6-488c-91dd-e28d637aa982','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','dc4d9fe1-e701-4484-9a80-46445ac07d7b','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:22:31.019102498+00:00');
INSERT INTO outcomes VALUES('43e0e0e0-0c49-4649-a934-ccfdcf9b9f24','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','e9b8f589-6b1b-4c05-b243-b202289a5891','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:23:00.929186270+00:00');
INSERT INTO outcomes VALUES('fba5b4aa-0c74-4c1d-bb69-c96e8d72da07','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','ef3741d5-fe61-4b4c-bb02-796808eb2f42','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:23:25.568098070+00:00');
INSERT INTO outcomes VALUES('db3180f9-5e9c-4a4c-8e0d-584a9dd661fd','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','f4766946-df88-41cf-8ddd-e52c0d739667','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T04:23:38.914065848+00:00');
INSERT INTO outcomes VALUES('dbbb8266-5f86-40e6-a803-b888766bbc3c','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','0175e72c-7fe6-463d-ba23-27aafd5c4404','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T13:24:50.126848283+00:00');
INSERT INTO outcomes VALUES('f31b3eca-8fd1-40a7-9c6e-bdeb4496f06d','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','063db326-e121-4dbd-8228-addac32f512c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:25:05.926217639+00:00');
INSERT INTO outcomes VALUES('8b8baed7-f421-4fbc-b3b5-d7f0a440fc9b','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','2068cd5c-c8ec-4d8b-acc1-fa3837954bbe','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:25:15.061335953+00:00');
INSERT INTO outcomes VALUES('33f77417-5874-415f-b5a1-a8285768629c','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','287dec24-33f8-418a-a91d-aa28609d2596','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:25:36.209634973+00:00');
INSERT INTO outcomes VALUES('c3f538fb-ac37-452e-8220-55969820ff25','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','39995993-b784-47f3-994f-ac9b5110ee9a','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:25:41.904366167+00:00');
INSERT INTO outcomes VALUES('050e748c-8dd0-4bc7-b72a-ca1ebb83c94c','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3a8c4401-4ef4-48d6-b192-99ad9cd5ea37','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:25:50.405096016+00:00');
INSERT INTO outcomes VALUES('5d8a61fb-11ad-4840-b313-0efd1c18b150','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3b4ac24a-df7e-4299-be5f-d15ab12a3533','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:25:55.194275723+00:00');
INSERT INTO outcomes VALUES('6c4dfe74-6fc3-4863-8fe7-2c5542236ffa','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3caeb4c7-a570-498a-a413-23e216dc426c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:26:02.658680602+00:00');
INSERT INTO outcomes VALUES('9c2217ad-305b-4c83-9241-0af9b54c7fa6','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3d608cc5-e48f-4c1a-93a9-b07b85018a95','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:26:12.994918622+00:00');
INSERT INTO outcomes VALUES('52685e5d-db74-4d17-9bd0-a5eabfa162c1','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','49e75eec-d95e-4e08-a69c-9d39e5598431','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:26:41.881459659+00:00');
INSERT INTO outcomes VALUES('efeae95b-137a-4b94-8fb5-73dbdd9a835b','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','4e927d2d-650a-40ea-bdd2-935fe131aacf','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:26:50.317548454+00:00');
INSERT INTO outcomes VALUES('3126b842-a46c-4c92-8762-0347fffa9f83','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','4fcc5aea-b0c3-441d-8c09-07053fb6679c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:27:04.617323837+00:00');
INSERT INTO outcomes VALUES('14b47419-9eb5-454f-b2ae-64ba7df37a15','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','5131162e-a407-476d-855c-1779b0bbc851','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:27:37.699174381+00:00');
INSERT INTO outcomes VALUES('f7e1c4ed-af22-4685-91e0-1f47171410f6','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','6348e526-30fd-49ce-95d5-bef9a49ecea8','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:27:46.562747948+00:00');
INSERT INTO outcomes VALUES('936c50af-ffe4-420e-85d2-078c2421c7e9','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','76a4a4b9-81ad-4980-841a-bff4f8e4d061','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:27:52.351227587+00:00');
INSERT INTO outcomes VALUES('6ab06820-a97b-4296-84a6-06b8cfc9701e','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','77c5f1b5-8604-407b-a696-9dde3b7e710a','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:27:59.374351700+00:00');
INSERT INTO outcomes VALUES('eef2d049-0351-4c5e-ba3f-1025dd2652e1','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','812a4352-66c5-4870-8940-f439b70bcc0f','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:28:26.795173714+00:00');
INSERT INTO outcomes VALUES('e3edf157-c1fd-4e27-be26-d9b1e7af6ee9','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','8803f7fa-49a5-4dff-8fd3-27b5c7fbba14','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:29:10.919838705+00:00');
INSERT INTO outcomes VALUES('83196ba7-a3c1-4687-b9de-5fb6fbeed1a9','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','8e43c714-33a9-4768-b0fa-f6839abfe27c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:29:23.341991959+00:00');
INSERT INTO outcomes VALUES('b40c7a02-83ba-4ee1-a607-f6e06caddab9','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9385f74c-1116-4ba4-87da-7691b3244181','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:29:36.191042173+00:00');
INSERT INTO outcomes VALUES('6e09ddfb-ac34-4cd6-b6b9-89b7fde8e66f','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','94f32ace-6458-4f44-aa65-3ee71c7f5869','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:29:44.924791370+00:00');
INSERT INTO outcomes VALUES('412de62e-1b5f-4277-9ddf-41a2240815cd','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9932566a-0717-4759-bf96-d3f5b1c72cb9','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:29:57.433001811+00:00');
INSERT INTO outcomes VALUES('6663bc8c-44b0-4faf-b92b-4e932d4f9489','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9a8eafd6-cc55-4dfb-932e-75728881fc73','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:30:07.753953788+00:00');
INSERT INTO outcomes VALUES('53621a0a-4c73-4353-9687-43e32dbb5676','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9cda4f06-c7de-47b0-928a-4cd76c936723','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:30:22.167832018+00:00');
INSERT INTO outcomes VALUES('aec12886-a48f-4bd8-a0c3-aea0ef06bd60','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','a0783fbf-a2b2-4dbe-b6b6-bbe5baf885db','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:30:43.629728697+00:00');
INSERT INTO outcomes VALUES('0e9b6673-2ed9-4b28-b048-f08c270b3ccd','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','a7a51b1b-0e38-4cdf-a8c9-9dd710d2549a','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:30:53.723378087+00:00');
INSERT INTO outcomes VALUES('9ab376e5-9b5d-4deb-804b-c372d896104d','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','b5f55bb7-8dd9-4a64-bda4-11df290902b2','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:31:03.366628868+00:00');
INSERT INTO outcomes VALUES('522c0dec-8f94-421f-a47b-1a0a01df9c1c','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','bfef8ce1-88bc-403b-81e7-21863f1d2e61','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:31:17.077604711+00:00');
INSERT INTO outcomes VALUES('7af1e394-b6bc-4fdb-8ced-895fedc28c7c','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','d0639627-725e-4157-9ee4-80ec0028fe2f','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:31:28.077152882+00:00');
INSERT INTO outcomes VALUES('60fd9d67-1695-468c-a924-5f8f1236f165','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','d27cd9e8-1bab-42de-a903-48317de1fec6','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:31:51.135855322+00:00');
INSERT INTO outcomes VALUES('95a5410a-9f9a-46db-901e-21f10392c4c0','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','dc4d9fe1-e701-4484-9a80-46445ac07d7b','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:32:07.470283754+00:00');
INSERT INTO outcomes VALUES('83e7bed8-e39c-4a4c-99b2-6874676c21e8','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','e9b8f589-6b1b-4c05-b243-b202289a5891','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:32:16.854042053+00:00');
INSERT INTO outcomes VALUES('3fb32751-78a8-4242-a37f-5d04b2b2444e','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','ef3741d5-fe61-4b4c-bb02-796808eb2f42','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:32:39.285774047+00:00');
INSERT INTO outcomes VALUES('c8eb6d6d-af43-4ad5-8269-2a396fe00768','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','f4766946-df88-41cf-8ddd-e52c0d739667','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T13:32:50.978849621+00:00');
CREATE UNIQUE INDEX task_versions_uniq_idx on task_versions
  (task_id, ifnull(parent_version_id, 0));
COMMIT;
