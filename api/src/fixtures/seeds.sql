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
      'acquireAbility',
      'acquireSkill',
      'answerQuestion',
      'completeProblem',
      'completeSet'
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
INSERT INTO tasks VALUES('c7299bc0-8604-4469-bec7-c449ba1bf060','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','acquireAbility','Ability to complete David Tolnay''s Rust Quiz without mistakes','2024-09-02 23:27:36',NULL,NULL);
INSERT INTO tasks VALUES('5bfdf4f7-c0bf-48eb-aa89-5643314738ec','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Problem to be solved','2024-09-05 00:01:53',NULL,NULL);
INSERT INTO tasks VALUES('15e8a1db-59e0-44bd-8fe6-ae79313f3971','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','23. Merge k Sorted Lists','2024-09-08 18:33:49',NULL,'https://leetcode.com/problems/merge-k-sorted-lists/description/');
INSERT INTO tasks VALUES('b22150f7-550e-49ab-9085-f02d447ff867','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','88. Merge Sorted Array','2024-09-08 18:58:08',NULL,'https://leetcode.com/problems/merge-sorted-array/description/');
INSERT INTO tasks VALUES('ec3b30d7-5cb8-4396-8da4-702985518910','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','977. Squares of a Sorted Array','2024-09-08 19:01:49',NULL,'https://leetcode.com/problems/squares-of-a-sorted-array/description/');
INSERT INTO tasks VALUES('c0b54ac2-30b8-4102-88e4-3e4cb48ff653','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeSet','Basic operations on sorted arrays and lists','2024-09-08 19:10:34','In this question set, we work through relatively simple problems involving sorted arrays.',NULL);
INSERT INTO tasks VALUES('02911bb3-f9d9-4782-99f5-fd99cad7d58a','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','21. Merge Two Sorted Lists','2024-09-08 19:37:31',NULL,'https://leetcode.com/problems/merge-two-sorted-lists/description/');
INSERT INTO tasks VALUES('4ccfb7d6-33ac-4a9d-8a5b-836b1d1010c9','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','26. Remove Duplicates from Sorted Array','2024-09-08 20:42:59',NULL,'https://leetcode.com/problems/remove-duplicates-from-sorted-array/description/');
INSERT INTO tasks VALUES('805d7cac-c2bb-4660-8845-f64295a4143c','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','4. Median of Two Sorted Arrays','2024-09-08 20:44:02',NULL,'https://leetcode.com/problems/median-of-two-sorted-arrays/description/');
INSERT INTO tasks VALUES('57e5dfc2-13c2-44cc-a6e5-b53c95847fc0','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeSet','Advanced operations on sorted arrays and lists','2024-09-08 20:44:53','Here we go through a series of harder challenges involving sorted arrays and lists.',NULL);
INSERT INTO tasks VALUES('a7363b4a-f56c-4fd6-b089-adcde780d266','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','2855. Minimum Right Shifts to Sort the Array','2024-09-08 20:46:32',NULL,'https://leetcode.com/problems/minimum-right-shifts-to-sort-the-array/description/');
INSERT INTO tasks VALUES('0e7b3a15-b703-4279-afc9-6ab872b23f4c','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','2089. Find Target Indices After Sorting Array','2024-09-08 20:47:52',NULL,'https://leetcode.com/problems/find-target-indices-after-sorting-array/description/');
INSERT INTO tasks VALUES('3455f0dc-df42-405c-a06a-b858b22d26f8','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','1636. Sort Array by Increasing Frequency','2024-09-08 20:48:38',NULL,'https://leetcode.com/problems/sort-array-by-increasing-frequency/description/');
INSERT INTO tasks VALUES('572fc922-8011-479e-99bf-03283fcc2920','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','922. Sort Array By Parity II','2024-09-08 20:49:23',NULL,'https://leetcode.com/problems/sort-array-by-parity-ii/description/');
INSERT INTO tasks VALUES('f3c47bf7-29bb-4c5f-8f6c-90e42c8f0ce3','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','905. Sort Array By Parity','2024-09-08 20:50:00',NULL,'https://leetcode.com/problems/sort-array-by-parity/description/');
INSERT INTO tasks VALUES('4081c895-39cd-4798-9ea5-be28d46fca8a','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','1287. Element Appearing More Than 25% In Sorted Array','2024-09-08 20:50:45',NULL,'https://leetcode.com/problems/element-appearing-more-than-25-in-sorted-array/description/');
INSERT INTO tasks VALUES('dd681aed-d622-4ae9-80dc-0212ee5bd9ee','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','1752. Check if Array Is Sorted and Rotated','2024-09-08 20:51:07',NULL,'https://leetcode.com/problems/check-if-array-is-sorted-and-rotated/description/');
INSERT INTO tasks VALUES('1002d189-7542-4c3a-ad07-e5d5b14cda4b','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','108. Convert Sorted Array to Binary Search Tree','2024-09-08 20:52:08',NULL,'https://leetcode.com/problems/convert-sorted-array-to-binary-search-tree/description/');
INSERT INTO tasks VALUES('23789feb-08bf-49c0-bdaa-d85dc4489e5b','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','944. Delete Columns to Make Sorted','2024-09-08 20:52:45',NULL,'https://leetcode.com/problems/delete-columns-to-make-sorted/description/');
INSERT INTO tasks VALUES('06879a84-f5a7-4ac2-a82c-d9ebea942251','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','83. Remove Duplicates from Sorted List','2024-09-08 20:53:16',NULL,'https://leetcode.com/problems/remove-duplicates-from-sorted-list/description/');
INSERT INTO tasks VALUES('048cf285-64c6-4858-ae64-0a7cd8822370','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeSet','Basic state machines','2024-09-08 21:23:40','In this question set, we work through basic simulations and state machines that model things going on in the world.',NULL);
INSERT INTO tasks VALUES('effcbfb3-5ef8-41d5-ae77-0d835a2b039c','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','2960. Count Tested Devices After Test Operations','2024-09-08 21:23:58',NULL,'https://leetcode.com/problems/count-tested-devices-after-test-operations/description/');
INSERT INTO tasks VALUES('54105084-dd63-45d1-bc8f-7288165550c7','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeSet','Intermediate problems involving tree data structures','2024-09-08 21:25:31','In this question set, we work through moderately challenging problems involving tree data structures.',NULL);
INSERT INTO tasks VALUES('a21cab5c-ab5e-43a2-aea6-94afc7bf88f4','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','427. Construct Quad Tree','2024-09-08 21:25:45',NULL,'https://leetcode.com/problems/construct-quad-tree/description/');
INSERT INTO tasks VALUES('b5615f6a-30d0-4be4-b4da-2ccfbe98c8f5','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','109. Convert Sorted List to Binary Search Tree','2024-09-08 21:38:20',NULL,'https://leetcode.com/problems/convert-sorted-list-to-binary-search-tree/description/');
INSERT INTO tasks VALUES('f5d29973-b68f-4443-a53d-e13e0bca9cf7','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeSet','Intermediate state machines','2024-09-08 23:32:36','In this question set, we work through moderately challenging problems involving state machines and simulations.',NULL);
INSERT INTO tasks VALUES('27fc0e9a-4153-49a4-ae5f-f8c1429c22f9','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','2365. Task Scheduler II','2024-09-08 23:32:52',NULL,'https://leetcode.com/problems/task-scheduler-ii/description/');
INSERT INTO tasks VALUES('cde3137d-1206-4951-96db-c226800d647b','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeSet','Challenging problems involving state machines','2024-09-08 23:33:56','In this question set, we work through challenging problems involving state machines and simulations.',NULL);
INSERT INTO tasks VALUES('e9aef668-bda4-4515-af3c-3cc010dd41ad','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','2132. Stamping the Grid','2024-09-08 23:34:07',NULL,'https://leetcode.com/problems/stamping-the-grid/description/');
INSERT INTO tasks VALUES('a43922c0-9cab-40f6-b973-36209a242759','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Challenging graph problems','2024-09-08 23:35:10','In this question set, we work through some challenging problems involving graphs.',NULL);
INSERT INTO tasks VALUES('370f49fa-d2c6-4440-a61e-08469c4abf97','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','1697. Checking Existence of Edge Length Limited Paths','2024-09-08 23:35:20',NULL,'https://leetcode.com/problems/checking-existence-of-edge-length-limited-paths/description/');
INSERT INTO tasks VALUES('1c529dcc-f971-4757-adef-f5031a1f6604','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','Intermediate string manipulation problems','2024-09-08 23:41:59','In this question set, we work through moderately challenging problems involving strings.',NULL);
INSERT INTO tasks VALUES('ec123b1e-2fe3-4bc6-b015-8953ce6ebd74','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','2135. Count Words Obtained After Adding a Letter','2024-09-08 23:42:21',NULL,'https://leetcode.com/problems/count-words-obtained-after-adding-a-letter/description/');
INSERT INTO tasks VALUES('e448982b-6677-4926-bf48-9b94f26d7fbe','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','1638. Count Substrings That Differ by One Character','2024-09-08 23:43:10',NULL,'https://leetcode.com/problems/count-substrings-that-differ-by-one-character/description/');
INSERT INTO tasks VALUES('08b56d69-6e39-47cd-a7a6-4ea4cbbec818','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','1717. Maximum Score From Removing Substrings','2024-09-08 23:43:41',NULL,'https://leetcode.com/problems/maximum-score-from-removing-substrings/description/');
INSERT INTO tasks VALUES('f13de44f-1047-4c57-8cc0-15fb85cea714','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','2111. Minimum Operations to Make the Array K-Increasing','2024-09-08 23:46:58',NULL,'https://leetcode.com/problems/minimum-operations-to-make-the-array-k-increasing/description/');
INSERT INTO tasks VALUES('c8c4ff0e-0ce9-4791-bb81-1910a2b957f3','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeSet','Intermediate problems involving linked lists','2024-09-13 02:05:13','In this question set, we work through moderately challenging problems involving linked lists.',NULL);
INSERT INTO tasks VALUES('452c4b44-0090-487a-b8aa-c8a40a72d0ef','bfeea3c3-1160-488f-aac7-16919b6da713','04e229c9-795e-4f3a-a79e-ec18b5c28b99','completeProblem','148. Sort List','2024-09-13 02:05:36',NULL,'https://leetcode.com/problems/sort-list/description/');
CREATE TABLE approaches (
  id text primary key,
  task_id text not null,
  summary text not null,
  unspecified boolean not null default 1,
  added_at datetime not null default current_timestamp,
  foreign key(task_id) references tasks(id) on delete cascade
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
INSERT INTO approaches VALUES('dd8cae1a-833a-425d-8dcb-46e6de411efb','15e8a1db-59e0-44bd-8fe6-ae79313f3971','Unspecified',1,'2024-09-08 18:33:49');
INSERT INTO approaches VALUES('cdbbfbae-f764-40f4-928d-ff1287981dc8','b22150f7-550e-49ab-9085-f02d447ff867','Unspecified',1,'2024-09-08 18:58:08');
INSERT INTO approaches VALUES('57983f2d-a72a-4635-b191-ac82b4d6ad1c','ec3b30d7-5cb8-4396-8da4-702985518910','Unspecified',1,'2024-09-08 19:01:49');
INSERT INTO approaches VALUES('79368449-52f3-4fd9-abe2-3d7cfc7df21d','c0b54ac2-30b8-4102-88e4-3e4cb48ff653','Unspecified',1,'2024-09-08 19:10:34');
INSERT INTO approaches VALUES('d57be927-b0b5-4c15-a8e8-482dcbf53573','02911bb3-f9d9-4782-99f5-fd99cad7d58a','Unspecified',1,'2024-09-08 19:37:31');
INSERT INTO approaches VALUES('c9f652ac-8248-4fcd-9d5c-c68933e675f5','4ccfb7d6-33ac-4a9d-8a5b-836b1d1010c9','Unspecified',1,'2024-09-08 20:42:59');
INSERT INTO approaches VALUES('2949c35e-240c-4678-b14a-8d2fed5c84c7','805d7cac-c2bb-4660-8845-f64295a4143c','Unspecified',1,'2024-09-08 20:44:02');
INSERT INTO approaches VALUES('f2592042-a3a9-4c00-8d61-89d046f3e68d','57e5dfc2-13c2-44cc-a6e5-b53c95847fc0','Unspecified',1,'2024-09-08 20:44:53');
INSERT INTO approaches VALUES('1f4b3c17-65d7-4280-8f0e-f36f0b0bebfe','a7363b4a-f56c-4fd6-b089-adcde780d266','Unspecified',1,'2024-09-08 20:46:32');
INSERT INTO approaches VALUES('b62f88a8-4003-417f-b314-32490d416a1a','0e7b3a15-b703-4279-afc9-6ab872b23f4c','Unspecified',1,'2024-09-08 20:47:52');
INSERT INTO approaches VALUES('7f14067b-45b8-4922-8566-bd1efc2dbb63','3455f0dc-df42-405c-a06a-b858b22d26f8','Unspecified',1,'2024-09-08 20:48:38');
INSERT INTO approaches VALUES('39751f5c-9a7b-4968-aab4-b7fae792b74c','572fc922-8011-479e-99bf-03283fcc2920','Unspecified',1,'2024-09-08 20:49:23');
INSERT INTO approaches VALUES('ad3ac821-4c82-4531-8e90-96ae7ff514b7','f3c47bf7-29bb-4c5f-8f6c-90e42c8f0ce3','Unspecified',1,'2024-09-08 20:50:00');
INSERT INTO approaches VALUES('48e9c8ca-b792-4f43-b96a-f7d8308f260f','4081c895-39cd-4798-9ea5-be28d46fca8a','Unspecified',1,'2024-09-08 20:50:45');
INSERT INTO approaches VALUES('4db3e886-dabb-47d0-b10d-74d29b20893b','dd681aed-d622-4ae9-80dc-0212ee5bd9ee','Unspecified',1,'2024-09-08 20:51:07');
INSERT INTO approaches VALUES('279110ba-91c2-4ab8-9723-a1ab656c4dad','1002d189-7542-4c3a-ad07-e5d5b14cda4b','Unspecified',1,'2024-09-08 20:52:08');
INSERT INTO approaches VALUES('c418aa0f-6cd3-4b53-809a-a97962545a26','23789feb-08bf-49c0-bdaa-d85dc4489e5b','Unspecified',1,'2024-09-08 20:52:45');
INSERT INTO approaches VALUES('8ebd65e6-6842-43ec-84d1-4e6ccff33323','06879a84-f5a7-4ac2-a82c-d9ebea942251','Unspecified',1,'2024-09-08 20:53:16');
INSERT INTO approaches VALUES('f8c8b3f8-b26d-4da3-9082-a19a747936bf','048cf285-64c6-4858-ae64-0a7cd8822370','Unspecified',1,'2024-09-08 21:23:40');
INSERT INTO approaches VALUES('48219a00-abb6-4513-a305-76460eab5c26','effcbfb3-5ef8-41d5-ae77-0d835a2b039c','Unspecified',1,'2024-09-08 21:23:58');
INSERT INTO approaches VALUES('67a52c91-d7b0-4723-b8f0-328a02e406ee','54105084-dd63-45d1-bc8f-7288165550c7','Unspecified',1,'2024-09-08 21:25:31');
INSERT INTO approaches VALUES('0de1c44e-f136-4e6f-a093-d37ddc4e78b0','a21cab5c-ab5e-43a2-aea6-94afc7bf88f4','Unspecified',1,'2024-09-08 21:25:45');
INSERT INTO approaches VALUES('b69e48d6-7bc0-49c4-96a9-547726f11f92','b5615f6a-30d0-4be4-b4da-2ccfbe98c8f5','Unspecified',1,'2024-09-08 21:38:20');
INSERT INTO approaches VALUES('c0348458-51f9-4264-8fed-37ba10f8cb57','f5d29973-b68f-4443-a53d-e13e0bca9cf7','Unspecified',1,'2024-09-08 23:32:36');
INSERT INTO approaches VALUES('b0b6ac94-fd0b-4922-9e8b-d0c89f93066b','27fc0e9a-4153-49a4-ae5f-f8c1429c22f9','Unspecified',1,'2024-09-08 23:32:52');
INSERT INTO approaches VALUES('4d74940f-7add-4ae2-b884-c688787b99a7','cde3137d-1206-4951-96db-c226800d647b','Unspecified',1,'2024-09-08 23:33:56');
INSERT INTO approaches VALUES('b5c91e70-1317-4d12-ad24-9c2a94ec9b0a','e9aef668-bda4-4515-af3c-3cc010dd41ad','Unspecified',1,'2024-09-08 23:34:07');
INSERT INTO approaches VALUES('50a7f614-d0d4-4c9a-a04a-d858b3da4cee','a43922c0-9cab-40f6-b973-36209a242759','Unspecified',1,'2024-09-08 23:35:10');
INSERT INTO approaches VALUES('016a4a7f-8d33-4117-887f-4479a0035f87','370f49fa-d2c6-4440-a61e-08469c4abf97','Unspecified',1,'2024-09-08 23:35:20');
INSERT INTO approaches VALUES('2412f190-e82b-4759-a2d0-3123fee713f5','1c529dcc-f971-4757-adef-f5031a1f6604','Unspecified',1,'2024-09-08 23:41:59');
INSERT INTO approaches VALUES('75376be8-00bf-49d7-9837-3bdcd86d1243','ec123b1e-2fe3-4bc6-b015-8953ce6ebd74','Unspecified',1,'2024-09-08 23:42:21');
INSERT INTO approaches VALUES('2c205a50-5d92-4c48-be68-2b9bb0d43915','e448982b-6677-4926-bf48-9b94f26d7fbe','Unspecified',1,'2024-09-08 23:43:10');
INSERT INTO approaches VALUES('3752db81-dcd6-4f5f-baf9-55b177d6c5cd','08b56d69-6e39-47cd-a7a6-4ea4cbbec818','Unspecified',1,'2024-09-08 23:43:41');
INSERT INTO approaches VALUES('b6ca2773-5614-429d-9608-9824f066caaa','f13de44f-1047-4c57-8cc0-15fb85cea714','Unspecified',1,'2024-09-08 23:46:58');
INSERT INTO approaches VALUES('fd8a40e9-3e02-4f93-8781-cbc3f2b0a699','c8c4ff0e-0ce9-4791-bb81-1910a2b957f3','Unspecified',1,'2024-09-13 02:05:13');
INSERT INTO approaches VALUES('03dadd60-e29e-4456-bae9-9814dd15c2ed','452c4b44-0090-487a-b8aa-c8a40a72d0ef','Unspecified',1,'2024-09-13 02:05:36');
CREATE TABLE approach_prereqs (
  id text primary key not null,
  approach_id text not null,
  prereq_approach_id text not null,
  added_at datetime not null default current_timestamp,
  foreign key(approach_id) references approaches(id) on delete cascade,
  foreign key(prereq_approach_id) references approaches(id) on delete cascade,
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
INSERT INTO approach_prereqs VALUES('0fb15550-aef7-4c94-8cba-b94ade42e22f','79368449-52f3-4fd9-abe2-3d7cfc7df21d','cdbbfbae-f764-40f4-928d-ff1287981dc8','2024-09-08 19:30:50');
INSERT INTO approach_prereqs VALUES('0f6959e5-34d4-4e24-bb56-cbf598286599','79368449-52f3-4fd9-abe2-3d7cfc7df21d','57983f2d-a72a-4635-b191-ac82b4d6ad1c','2024-09-08 19:34:29');
INSERT INTO approach_prereqs VALUES('d4d53337-4354-4394-95d5-e4eaef70f444','79368449-52f3-4fd9-abe2-3d7cfc7df21d','d57be927-b0b5-4c15-a8e8-482dcbf53573','2024-09-08 19:37:49');
INSERT INTO approach_prereqs VALUES('975cbc61-929c-406d-ba0f-c7847c26cb95','79368449-52f3-4fd9-abe2-3d7cfc7df21d','c9f652ac-8248-4fcd-9d5c-c68933e675f5','2024-09-08 20:43:18');
INSERT INTO approach_prereqs VALUES('d7f58824-b3cd-46ec-998d-1a34b52b68d1','f2592042-a3a9-4c00-8d61-89d046f3e68d','2949c35e-240c-4678-b14a-8d2fed5c84c7','2024-09-08 20:45:02');
INSERT INTO approach_prereqs VALUES('fa5ff189-b68f-48a2-a64f-feb4597de0f6','f2592042-a3a9-4c00-8d61-89d046f3e68d','dd8cae1a-833a-425d-8dcb-46e6de411efb','2024-09-08 20:45:13');
INSERT INTO approach_prereqs VALUES('df60e08f-c369-45b1-ac68-01bac5aa31c8','79368449-52f3-4fd9-abe2-3d7cfc7df21d','1f4b3c17-65d7-4280-8f0e-f36f0b0bebfe','2024-09-08 20:46:43');
INSERT INTO approach_prereqs VALUES('ab41be6d-18c9-466f-bc02-a323475e3d27','79368449-52f3-4fd9-abe2-3d7cfc7df21d','b62f88a8-4003-417f-b314-32490d416a1a','2024-09-08 20:48:04');
INSERT INTO approach_prereqs VALUES('b7b83e5b-6b24-4bd5-bd06-9cac6b204c50','79368449-52f3-4fd9-abe2-3d7cfc7df21d','7f14067b-45b8-4922-8566-bd1efc2dbb63','2024-09-08 20:48:51');
INSERT INTO approach_prereqs VALUES('6f2762d7-5ecc-450d-87c5-c2592a1ce79d','79368449-52f3-4fd9-abe2-3d7cfc7df21d','39751f5c-9a7b-4968-aab4-b7fae792b74c','2024-09-08 20:49:31');
INSERT INTO approach_prereqs VALUES('dd43fab9-ecb4-4e52-8815-c356accfb458','79368449-52f3-4fd9-abe2-3d7cfc7df21d','ad3ac821-4c82-4531-8e90-96ae7ff514b7','2024-09-08 20:50:20');
INSERT INTO approach_prereqs VALUES('166b783c-8daf-441f-bb0d-0f97dd5b5469','79368449-52f3-4fd9-abe2-3d7cfc7df21d','48e9c8ca-b792-4f43-b96a-f7d8308f260f','2024-09-08 20:50:52');
INSERT INTO approach_prereqs VALUES('5c126a68-b9a3-4ab4-a17e-f07827548ebe','79368449-52f3-4fd9-abe2-3d7cfc7df21d','4db3e886-dabb-47d0-b10d-74d29b20893b','2024-09-08 20:51:14');
INSERT INTO approach_prereqs VALUES('a0b2355e-353c-4fbb-9c5c-5d3e54ceffc0','79368449-52f3-4fd9-abe2-3d7cfc7df21d','279110ba-91c2-4ab8-9723-a1ab656c4dad','2024-09-08 20:52:24');
INSERT INTO approach_prereqs VALUES('4c1c1937-c0ca-449d-9f91-2c06779ed908','79368449-52f3-4fd9-abe2-3d7cfc7df21d','c418aa0f-6cd3-4b53-809a-a97962545a26','2024-09-08 20:52:51');
INSERT INTO approach_prereqs VALUES('40d07afd-292f-4543-91e3-6577d3ef47c9','79368449-52f3-4fd9-abe2-3d7cfc7df21d','8ebd65e6-6842-43ec-84d1-4e6ccff33323','2024-09-08 20:53:23');
INSERT INTO approach_prereqs VALUES('fccbe285-442b-40f2-8cd4-9b2715165a19','f8c8b3f8-b26d-4da3-9082-a19a747936bf','48219a00-abb6-4513-a305-76460eab5c26','2024-09-08 21:24:08');
INSERT INTO approach_prereqs VALUES('38bde80b-8177-4678-ab7b-0573edcee5ca','67a52c91-d7b0-4723-b8f0-328a02e406ee','0de1c44e-f136-4e6f-a093-d37ddc4e78b0','2024-09-08 21:25:55');
INSERT INTO approach_prereqs VALUES('94f2bbaa-a795-48a3-adba-4af953d7b634','67a52c91-d7b0-4723-b8f0-328a02e406ee','b69e48d6-7bc0-49c4-96a9-547726f11f92','2024-09-08 21:38:39');
INSERT INTO approach_prereqs VALUES('0cdc521d-7ecd-49ea-bfb0-8a524cc3440a','c0348458-51f9-4264-8fed-37ba10f8cb57','b0b6ac94-fd0b-4922-9e8b-d0c89f93066b','2024-09-08 23:33:04');
INSERT INTO approach_prereqs VALUES('daf99e79-3e54-4a4b-9ac6-58a44351b24a','4d74940f-7add-4ae2-b884-c688787b99a7','b5c91e70-1317-4d12-ad24-9c2a94ec9b0a','2024-09-08 23:34:16');
INSERT INTO approach_prereqs VALUES('fc8e71b3-4683-400a-9fd0-ae31f303e24a','50a7f614-d0d4-4c9a-a04a-d858b3da4cee','016a4a7f-8d33-4117-887f-4479a0035f87','2024-09-08 23:35:28');
INSERT INTO approach_prereqs VALUES('c11d19fc-2bb2-44cd-a18b-7093c1462453','2412f190-e82b-4759-a2d0-3123fee713f5','75376be8-00bf-49d7-9837-3bdcd86d1243','2024-09-08 23:42:29');
INSERT INTO approach_prereqs VALUES('d23cf8e7-3c3e-4fe2-9c4e-7da8fa2fc546','2412f190-e82b-4759-a2d0-3123fee713f5','2c205a50-5d92-4c48-be68-2b9bb0d43915','2024-09-08 23:43:23');
INSERT INTO approach_prereqs VALUES('0d8176b4-e01b-4521-a531-d7341afa608f','2412f190-e82b-4759-a2d0-3123fee713f5','3752db81-dcd6-4f5f-baf9-55b177d6c5cd','2024-09-08 23:43:50');
INSERT INTO approach_prereqs VALUES('c5528874-5536-4535-a548-efe4239e3f0e','f2592042-a3a9-4c00-8d61-89d046f3e68d','b6ca2773-5614-429d-9608-9824f066caaa','2024-09-08 23:47:31');
INSERT INTO approach_prereqs VALUES('0457da0f-9aee-4db8-83b7-852bce43ecb0','fd8a40e9-3e02-4f93-8781-cbc3f2b0a699','03dadd60-e29e-4456-bae9-9814dd15c2ed','2024-09-13 02:05:46');
CREATE TABLE queues (
  id text primary key not null,
  user_id text not null default '04e229c9-795e-4f3a-a79e-ec18b5c28b99',
  -- repo_id text not null default 'bfeea3c3-1160-488f-aac7-16919b6da713',
  strategy text check( strategy in ('spacedRepetitionV1', 'deterministic') ) not null default 'spacedRepetitionV1',
  cadence text check( cadence in ('minutes', 'hours', 'days') ) not null default 'days',
  summary text not null,
  target_approach_id text not null,
  added_at timestamp not null default current_timestamp,
  foreign key(target_approach_id) references approaches(id) on delete cascade,
  foreign key(user_id) references users(id)
);
INSERT INTO queues VALUES('34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','spacedRepetitionV1','days','David Tolnay''s Rust quiz','81359cd2-ec5f-498f-b9c4-281a1d034e59','2024-09-05 00:14:05');
INSERT INTO queues VALUES('6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','spacedRepetitionV1','days','Basic operations on sorted arrays and lists','79368449-52f3-4fd9-abe2-3d7cfc7df21d','2024-09-08 21:00:19');
INSERT INTO queues VALUES('d30fdb5c-91b1-4810-aaec-85f61b4fd3f0','04e229c9-795e-4f3a-a79e-ec18b5c28b99','spacedRepetitionV1','hours','Intermediate string manipulation problems','2412f190-e82b-4759-a2d0-3123fee713f5','2024-09-14 19:04:58');
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
INSERT INTO queue_tracks VALUES('1869c90b-ca20-445b-9f2c-5d292d8b90bc','6af9f952-ac11-4020-a23d-072685da38da','f56be999-86d8-4394-a69c-4882e3bfad70','af3f8556-654a-45a7-9c16-cf745a0e0f50','2024-09-08 21:05:47');
INSERT INTO queue_tracks VALUES('252e8075-871c-4373-8ba8-7d23e0e68a93','d30fdb5c-91b1-4810-aaec-85f61b4fd3f0','f56be999-86d8-4394-a69c-4882e3bfad70','af3f8556-654a-45a7-9c16-cf745a0e0f50','2024-09-14 19:05:18');
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
  foreign key(approach_id) references approaches(id) on delete cascade,
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
INSERT INTO outcomes VALUES('a59cde87-69cd-4c1e-b0c5-ab5f44349d9b','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','063db326-e121-4dbd-8228-addac32f512c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:02:14.362098658+00:00');
INSERT INTO outcomes VALUES('b09e71ea-7d2d-4ecf-a781-0405b2d96107','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','2068cd5c-c8ec-4d8b-acc1-fa3837954bbe','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:02:22.817295425+00:00');
INSERT INTO outcomes VALUES('24e884bb-97ac-429a-88b4-5039cd7aa707','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','287dec24-33f8-418a-a91d-aa28609d2596','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:02:34.601907135+00:00');
INSERT INTO outcomes VALUES('04ebb866-f7aa-4c7c-ad16-35c22a4355cd','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','39995993-b784-47f3-994f-ac9b5110ee9a','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:02:41.088876079+00:00');
INSERT INTO outcomes VALUES('b2e24921-1d7d-47cb-88bc-250847646e12','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3a8c4401-4ef4-48d6-b192-99ad9cd5ea37','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:02:52.520448231+00:00');
INSERT INTO outcomes VALUES('0c2b591a-a906-44ba-b08c-abd018eb4a58','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3b4ac24a-df7e-4299-be5f-d15ab12a3533','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:03:00.933256118+00:00');
INSERT INTO outcomes VALUES('9ae5e381-6ca9-4478-8419-f21936455c43','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3caeb4c7-a570-498a-a413-23e216dc426c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:03:11.037441018+00:00');
INSERT INTO outcomes VALUES('7aff2f44-7eb6-4b6e-a851-244e581c18af','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3d608cc5-e48f-4c1a-93a9-b07b85018a95','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:03:18.379318692+00:00');
INSERT INTO outcomes VALUES('b1aad987-23a9-4755-b260-50661ce30826','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','49e75eec-d95e-4e08-a69c-9d39e5598431','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:03:31.822180026+00:00');
INSERT INTO outcomes VALUES('84419642-917e-4402-9893-287edd03ebc5','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','4e927d2d-650a-40ea-bdd2-935fe131aacf','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:03:39.888615611+00:00');
INSERT INTO outcomes VALUES('13a9ea1e-2bf2-4002-8b45-2734e2e6da23','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','4fcc5aea-b0c3-441d-8c09-07053fb6679c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:03:52.815187341+00:00');
INSERT INTO outcomes VALUES('376689ca-7a65-4cdb-8bdf-196aa717e3aa','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','5131162e-a407-476d-855c-1779b0bbc851','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:04:04.805229288+00:00');
INSERT INTO outcomes VALUES('ffef6fcf-0a04-45a7-a9ed-194ac6d59aeb','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','6348e526-30fd-49ce-95d5-bef9a49ecea8','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:04:12.231312058+00:00');
INSERT INTO outcomes VALUES('abcc5feb-4152-4cc5-8505-67dde5eaaf51','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','76a4a4b9-81ad-4980-841a-bff4f8e4d061','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:04:19.208015259+00:00');
INSERT INTO outcomes VALUES('3f803c9b-c4e9-4e21-a2e6-992769d5cd26','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','77c5f1b5-8604-407b-a696-9dde3b7e710a','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:04:26.507358090+00:00');
INSERT INTO outcomes VALUES('12d7fe20-3833-4f6c-b20d-a9049e0a7060','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','812a4352-66c5-4870-8940-f439b70bcc0f','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:04:40.795434788+00:00');
INSERT INTO outcomes VALUES('a39ac6a9-3b52-4a14-be47-f8f1627e6d66','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','8803f7fa-49a5-4dff-8fd3-27b5c7fbba14','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:04:52.062320785+00:00');
INSERT INTO outcomes VALUES('5171bd2c-814d-4dbf-8315-02e04938cdc5','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','8e43c714-33a9-4768-b0fa-f6839abfe27c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:05:02.577184203+00:00');
INSERT INTO outcomes VALUES('fc18bbd6-c7b0-4696-b802-1829a08de1e3','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9385f74c-1116-4ba4-87da-7691b3244181','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:05:13.200503038+00:00');
INSERT INTO outcomes VALUES('8b9a0ed9-c460-4b05-aa06-0bbcb586014a','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','94f32ace-6458-4f44-aa65-3ee71c7f5869','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:05:21.133425755+00:00');
INSERT INTO outcomes VALUES('1637373a-c361-4b9f-91df-feb97df246b1','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9932566a-0717-4759-bf96-d3f5b1c72cb9','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:05:41.830308256+00:00');
INSERT INTO outcomes VALUES('b9d74bdf-c020-49eb-aa3f-f2fd4bd78c0d','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9a8eafd6-cc55-4dfb-932e-75728881fc73','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:05:56.665861599+00:00');
INSERT INTO outcomes VALUES('85c3e55d-fa75-494f-aa2c-d1be1803bfe7','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9cda4f06-c7de-47b0-928a-4cd76c936723','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:06:30.775984540+00:00');
INSERT INTO outcomes VALUES('ec17581b-b1a7-49aa-a1c1-081755148674','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','a0783fbf-a2b2-4dbe-b6b6-bbe5baf885db','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:06:36.505321798+00:00');
INSERT INTO outcomes VALUES('e136b2c9-200c-4085-8a36-f99ef8891d70','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','a7a51b1b-0e38-4cdf-a8c9-9dd710d2549a','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:06:43.859031521+00:00');
INSERT INTO outcomes VALUES('9ad80b37-7205-42a9-9e01-502f5fef0a35','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','b5f55bb7-8dd9-4a64-bda4-11df290902b2','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:06:53.166203842+00:00');
INSERT INTO outcomes VALUES('6d3e37d6-92ba-4ce5-9785-6c1e946b27eb','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','bfef8ce1-88bc-403b-81e7-21863f1d2e61','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:07:09.380025238+00:00');
INSERT INTO outcomes VALUES('3a98b3db-5671-4e78-9421-b754bf1a2821','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','d0639627-725e-4157-9ee4-80ec0028fe2f','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:07:19.168324655+00:00');
INSERT INTO outcomes VALUES('63763110-1662-4ac0-9d80-a5ecf3d680f9','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','d27cd9e8-1bab-42de-a903-48317de1fec6','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:07:37.709405405+00:00');
INSERT INTO outcomes VALUES('97fd4131-272f-4335-bf1b-617d3e56803f','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','dc4d9fe1-e701-4484-9a80-46445ac07d7b','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:07:55.263184550+00:00');
INSERT INTO outcomes VALUES('d2db1532-2a25-450b-8472-7c88c518c1aa','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','e9b8f589-6b1b-4c05-b243-b202289a5891','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:08:05.078181684+00:00');
INSERT INTO outcomes VALUES('de9749d5-d4b7-40b9-9e35-8c6291a64164','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','ef3741d5-fe61-4b4c-bb02-796808eb2f42','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:08:22.945063971+00:00');
INSERT INTO outcomes VALUES('6b4e9c9f-e47b-4db4-b4fa-d82dd94180f7','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','f4766946-df88-41cf-8ddd-e52c0d739667','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-08T19:08:34.542245572+00:00');
INSERT INTO outcomes VALUES('435163d0-d4a7-4d03-a862-d7f6689ad8cc','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','1f4b3c17-65d7-4280-8f0e-f36f0b0bebfe','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T21:17:47.958618251+00:00');
INSERT INTO outcomes VALUES('1b3a7bd5-6303-4b55-bb45-863ae9c54e52','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','279110ba-91c2-4ab8-9723-a1ab656c4dad','af3f8556-654a-45a7-9c16-cf745a0e0f50','tooHard',0,'2024-09-08T21:39:50.480887840+00:00');
INSERT INTO outcomes VALUES('8de79652-4470-41e2-8cd8-6298246c6279','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','39751f5c-9a7b-4968-aab4-b7fae792b74c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T22:14:11.324946432+00:00');
INSERT INTO outcomes VALUES('82035ac9-6b7f-486c-91d4-c1e5bffbe64c','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','0175e72c-7fe6-463d-ba23-27aafd5c4404','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-08T22:21:47.949161051+00:00');
INSERT INTO outcomes VALUES('465ef096-b460-4ccd-ab45-4e6ee3f1d7ae','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','48e9c8ca-b792-4f43-b96a-f7d8308f260f','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T22:32:20.287470530+00:00');
INSERT INTO outcomes VALUES('e831e287-4acd-4e89-b079-c9b882f6d831','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','1f4b3c17-65d7-4280-8f0e-f36f0b0bebfe','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-08T23:30:59.216711075+00:00');
INSERT INTO outcomes VALUES('a37d32e8-d242-4f82-ad56-3c8fdeacd50b','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','4db3e886-dabb-47d0-b10d-74d29b20893b','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T23:40:02.418759530+00:00');
INSERT INTO outcomes VALUES('6497b676-4e6c-45b9-a1ce-8d731978d285','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','57983f2d-a72a-4635-b191-ac82b4d6ad1c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-08T23:55:25.322396454+00:00');
INSERT INTO outcomes VALUES('472d53ca-ec0b-45b3-9ec9-b4d425287090','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','7f14067b-45b8-4922-8566-bd1efc2dbb63','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-09T00:01:48.617028996+00:00');
INSERT INTO outcomes VALUES('6c301318-1b95-485d-af5e-d864945225f9','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','8ebd65e6-6842-43ec-84d1-4e6ccff33323','af3f8556-654a-45a7-9c16-cf745a0e0f50','tooHard',0,'2024-09-09T00:13:17.148581475+00:00');
INSERT INTO outcomes VALUES('542b908d-0a75-4796-bb1f-94b878c53f5a','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','ad3ac821-4c82-4531-8e90-96ae7ff514b7','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-09T00:15:19.980970879+00:00');
INSERT INTO outcomes VALUES('b22d9060-14bc-443f-9f98-8ac8b3aaed87','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','39751f5c-9a7b-4968-aab4-b7fae792b74c','af3f8556-654a-45a7-9c16-cf745a0e0f50','needsRetry',0,'2024-09-09T00:25:40.218484500+00:00');
INSERT INTO outcomes VALUES('43ec667e-aeb2-4cc7-a0e4-3113fae7c210','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','48e9c8ca-b792-4f43-b96a-f7d8308f260f','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-09T02:08:39.757426998+00:00');
INSERT INTO outcomes VALUES('b743efd2-c27f-4a2e-9883-72887864eb36','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','4db3e886-dabb-47d0-b10d-74d29b20893b','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-09T02:11:09.052632523+00:00');
INSERT INTO outcomes VALUES('7f1e529b-b8f1-4463-a66f-a7113107f039','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','57983f2d-a72a-4635-b191-ac82b4d6ad1c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-09T02:12:45.036766184+00:00');
INSERT INTO outcomes VALUES('ec29f6fd-1a33-466c-ace0-358e7788e4e9','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','7f14067b-45b8-4922-8566-bd1efc2dbb63','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-09T02:17:07.573231344+00:00');
INSERT INTO outcomes VALUES('78b24ba4-ce30-4c86-87cf-297fccfdec8a','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','ad3ac821-4c82-4531-8e90-96ae7ff514b7','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-09T02:18:51.475879764+00:00');
INSERT INTO outcomes VALUES('42d0c22b-f6a4-4090-800d-3f40ac4aa039','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','39751f5c-9a7b-4968-aab4-b7fae792b74c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-09T02:23:04.028154265+00:00');
INSERT INTO outcomes VALUES('88abd4f8-462b-42a9-9469-625984d0421a','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','b62f88a8-4003-417f-b314-32490d416a1a','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-09T02:26:24.714886694+00:00');
INSERT INTO outcomes VALUES('d5328723-478b-4593-8900-5cd417815e0a','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','c418aa0f-6cd3-4b53-809a-a97962545a26','af3f8556-654a-45a7-9c16-cf745a0e0f50','needsRetry',0,'2024-09-09T02:38:17.863215151+00:00');
INSERT INTO outcomes VALUES('4f6221e3-51c2-471b-b21f-f95c2d389dc5','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','c9f652ac-8248-4fcd-9d5c-c68933e675f5','af3f8556-654a-45a7-9c16-cf745a0e0f50','needsRetry',0,'2024-09-09T03:14:15.781346361+00:00');
INSERT INTO outcomes VALUES('57a3a59c-1159-445a-be6c-0309d4437772','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','063db326-e121-4dbd-8228-addac32f512c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:18:13.253240549+00:00');
INSERT INTO outcomes VALUES('37eb9db9-b10b-4c21-81de-acf2672b6d78','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','2068cd5c-c8ec-4d8b-acc1-fa3837954bbe','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:18:27.166315649+00:00');
INSERT INTO outcomes VALUES('9d3a7344-d29d-4f9d-94c7-e110fda67acb','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','287dec24-33f8-418a-a91d-aa28609d2596','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:18:46.607537433+00:00');
INSERT INTO outcomes VALUES('9e47bafd-1084-4e9b-afdc-46de0d591eda','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','39995993-b784-47f3-994f-ac9b5110ee9a','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:18:54.662520286+00:00');
INSERT INTO outcomes VALUES('87c26de0-fa76-4f2a-963e-01819b327498','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3a8c4401-4ef4-48d6-b192-99ad9cd5ea37','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:19:08.887551426+00:00');
INSERT INTO outcomes VALUES('c0be4525-1af5-4aaa-9f92-90f8b0ded622','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3b4ac24a-df7e-4299-be5f-d15ab12a3533','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:19:16.448044617+00:00');
INSERT INTO outcomes VALUES('ec753821-e0a7-4531-ae52-bfd10dca0c0f','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3caeb4c7-a570-498a-a413-23e216dc426c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:19:29.649474651+00:00');
INSERT INTO outcomes VALUES('e5afe6cd-dcb8-4e4f-abc9-a1557aa9c29d','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','3d608cc5-e48f-4c1a-93a9-b07b85018a95','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:19:36.559243838+00:00');
INSERT INTO outcomes VALUES('f53b2c2b-25cf-4107-8f15-33ac7ee63628','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','49e75eec-d95e-4e08-a69c-9d39e5598431','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:19:50.282309888+00:00');
INSERT INTO outcomes VALUES('e7b2ab18-59cd-4b1b-be6a-0ffcdbcf8788','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','4e927d2d-650a-40ea-bdd2-935fe131aacf','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:20:02.807597153+00:00');
INSERT INTO outcomes VALUES('a3ca5511-ef64-44b3-8b07-6b9e91eb40e7','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','4fcc5aea-b0c3-441d-8c09-07053fb6679c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:20:20.545406539+00:00');
INSERT INTO outcomes VALUES('48d0eda9-bcd2-418e-9d81-05d387808cfb','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','5131162e-a407-476d-855c-1779b0bbc851','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:20:36.381362389+00:00');
INSERT INTO outcomes VALUES('5a019572-8da2-4f38-a5c8-5ca21c0487c2','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','6348e526-30fd-49ce-95d5-bef9a49ecea8','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:20:49.197195812+00:00');
INSERT INTO outcomes VALUES('98cf791a-71ce-48e4-bcec-b829d22f62e3','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','76a4a4b9-81ad-4980-841a-bff4f8e4d061','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:20:57.958253885+00:00');
INSERT INTO outcomes VALUES('6cfade6c-dc93-430b-85e5-c6f8c7d22d08','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','77c5f1b5-8604-407b-a696-9dde3b7e710a','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:21:08.364488922+00:00');
INSERT INTO outcomes VALUES('7fcd9189-95b4-43b7-b301-09d2d4a9c277','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','812a4352-66c5-4870-8940-f439b70bcc0f','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:21:23.753166141+00:00');
INSERT INTO outcomes VALUES('5e4686a9-db9b-4af1-8d38-fe6d04c4d298','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','8803f7fa-49a5-4dff-8fd3-27b5c7fbba14','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:21:34.814328917+00:00');
INSERT INTO outcomes VALUES('c3e47518-7fc4-4f6d-a476-ff64f5a31534','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','8e43c714-33a9-4768-b0fa-f6839abfe27c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:21:45.015757977+00:00');
INSERT INTO outcomes VALUES('59a790f9-4c1b-4128-9d8a-0f0f2e4566b2','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9385f74c-1116-4ba4-87da-7691b3244181','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:21:53.771348431+00:00');
INSERT INTO outcomes VALUES('2089d8bf-5b8d-4731-a8b3-0b4b039114a0','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','94f32ace-6458-4f44-aa65-3ee71c7f5869','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:22:05.265556524+00:00');
INSERT INTO outcomes VALUES('8495d12b-f105-4000-9d7c-c9fabf890715','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9932566a-0717-4759-bf96-d3f5b1c72cb9','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:22:16.402077113+00:00');
INSERT INTO outcomes VALUES('6997c538-7bcb-4441-9c8f-745bdb93536d','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9a8eafd6-cc55-4dfb-932e-75728881fc73','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:22:24.064776884+00:00');
INSERT INTO outcomes VALUES('157864f2-80c7-4132-835e-0d3ece304978','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','9cda4f06-c7de-47b0-928a-4cd76c936723','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:22:34.475334498+00:00');
INSERT INTO outcomes VALUES('2f5b7f62-2a84-422b-8819-d90ea1b77bb5','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','a0783fbf-a2b2-4dbe-b6b6-bbe5baf885db','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:22:40.317901620+00:00');
INSERT INTO outcomes VALUES('b4e01dd5-29bd-4aa5-9a3e-75586211b4e5','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','a7a51b1b-0e38-4cdf-a8c9-9dd710d2549a','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:22:49.298012435+00:00');
INSERT INTO outcomes VALUES('f7a8de75-b223-413c-8645-8014045df175','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','b5f55bb7-8dd9-4a64-bda4-11df290902b2','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:22:57.949955438+00:00');
INSERT INTO outcomes VALUES('7872f229-4423-4fe1-920a-a9cc6cf8668a','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','bfef8ce1-88bc-403b-81e7-21863f1d2e61','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:23:08.560149425+00:00');
INSERT INTO outcomes VALUES('6080852c-e83c-45b0-aa11-29e5b1205631','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','d0639627-725e-4157-9ee4-80ec0028fe2f','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:23:17.573925584+00:00');
INSERT INTO outcomes VALUES('a3efe47a-2d28-4b22-9744-2f68420f9622','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','d27cd9e8-1bab-42de-a903-48317de1fec6','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:23:26.361810484+00:00');
INSERT INTO outcomes VALUES('8d853b3a-9cbd-4c1e-8824-8d51cd0b71f7','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','dc4d9fe1-e701-4484-9a80-46445ac07d7b','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:23:40.331595939+00:00');
INSERT INTO outcomes VALUES('547e5306-b736-4746-8a86-515e735cdcf3','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','e9b8f589-6b1b-4c05-b243-b202289a5891','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:23:48.781114004+00:00');
INSERT INTO outcomes VALUES('ee20e023-9c47-4e86-87a2-79b3c18a12db','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','ef3741d5-fe61-4b4c-bb02-796808eb2f42','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:24:03.223240384+00:00');
INSERT INTO outcomes VALUES('a87700c6-d993-4e04-8fc8-41319a8cba8d','34b1de9d-ac94-433c-8369-0e121e97af43','04e229c9-795e-4f3a-a79e-ec18b5c28b99','f4766946-df88-41cf-8ddd-e52c0d739667','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',4,'2024-09-09T03:24:14.682070097+00:00');
INSERT INTO outcomes VALUES('0f0ddec5-4210-4735-b8ac-b6bf6c4d1ab8','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','1f4b3c17-65d7-4280-8f0e-f36f0b0bebfe','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-10T23:28:26.671242465+00:00');
INSERT INTO outcomes VALUES('a08b6eea-ef7f-4791-9295-33cba757c872','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','48e9c8ca-b792-4f43-b96a-f7d8308f260f','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-10T23:33:09.369525079+00:00');
INSERT INTO outcomes VALUES('4cc6314f-f34f-4f31-9bb1-acfc8a846a51','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','4db3e886-dabb-47d0-b10d-74d29b20893b','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-10T23:36:56.562990058+00:00');
INSERT INTO outcomes VALUES('2c6caa33-6c65-423c-bc69-015f2a257703','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','57983f2d-a72a-4635-b191-ac82b4d6ad1c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-10T23:38:53.537213549+00:00');
INSERT INTO outcomes VALUES('68103af8-3e0c-47fd-8428-21f4fac86c4a','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','7f14067b-45b8-4922-8566-bd1efc2dbb63','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-10T23:42:50.892809692+00:00');
INSERT INTO outcomes VALUES('30ac4582-8102-41ba-8db7-41596c871185','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','ad3ac821-4c82-4531-8e90-96ae7ff514b7','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',3,'2024-09-10T23:44:10.965055332+00:00');
INSERT INTO outcomes VALUES('ff1d782e-f26b-4474-8ce7-dd8fd8c74640','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','39751f5c-9a7b-4968-aab4-b7fae792b74c','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-10T23:48:15.372881890+00:00');
INSERT INTO outcomes VALUES('04f0869f-c8ec-4e6a-9f85-8a159a85d6fc','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','b62f88a8-4003-417f-b314-32490d416a1a','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-10T23:51:08.584318669+00:00');
INSERT INTO outcomes VALUES('231a0ed9-28b6-40fd-a915-1fe99f99ee1b','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','c418aa0f-6cd3-4b53-809a-a97962545a26','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-10T23:54:56.273804301+00:00');
INSERT INTO outcomes VALUES('fefcb624-8428-4951-889f-efdc3b5723a0','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','c9f652ac-8248-4fcd-9d5c-c68933e675f5','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-11T00:00:32.629291006+00:00');
INSERT INTO outcomes VALUES('438816a5-c8bc-4f21-929c-1b2901b84901','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','cdbbfbae-f764-40f4-928d-ff1287981dc8','af3f8556-654a-45a7-9c16-cf745a0e0f50','needsRetry',0,'2024-09-11T00:22:30.175444459+00:00');
INSERT INTO outcomes VALUES('3033e13d-6608-4bce-872a-623557ecaa6e','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','d57be927-b0b5-4c15-a8e8-482dcbf53573','af3f8556-654a-45a7-9c16-cf745a0e0f50','needsRetry',0,'2024-09-11T00:45:57.229725092+00:00');
INSERT INTO outcomes VALUES('3f31be5a-d8f7-4a09-ae98-c24769deee97','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','c418aa0f-6cd3-4b53-809a-a97962545a26','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-13T01:09:23.779254299+00:00');
INSERT INTO outcomes VALUES('8d6a2b6b-bb36-42ff-86de-b54d4d379b6a','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','c9f652ac-8248-4fcd-9d5c-c68933e675f5','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',2,'2024-09-13T01:13:21.733088844+00:00');
INSERT INTO outcomes VALUES('27cec49e-ab18-40e4-8d38-6f7151431ec3','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','cdbbfbae-f764-40f4-928d-ff1287981dc8','af3f8556-654a-45a7-9c16-cf745a0e0f50','needsRetry',0,'2024-09-13T01:51:09.119111368+00:00');
INSERT INTO outcomes VALUES('169f1898-8f1c-4bdd-a38e-183c9d979551','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','d57be927-b0b5-4c15-a8e8-482dcbf53573','af3f8556-654a-45a7-9c16-cf745a0e0f50','tooHard',0,'2024-09-13T01:56:58.827594608+00:00');
INSERT INTO outcomes VALUES('d022c987-6a7c-426e-8561-d30736c3d45f','6af9f952-ac11-4020-a23d-072685da38da','04e229c9-795e-4f3a-a79e-ec18b5c28b99','cdbbfbae-f764-40f4-928d-ff1287981dc8','af3f8556-654a-45a7-9c16-cf745a0e0f50','completed',1,'2024-09-14T19:04:29.189559878+00:00');
CREATE UNIQUE INDEX task_versions_uniq_idx on task_versions
  (task_id, ifnull(parent_version_id, 0));
COMMIT;
