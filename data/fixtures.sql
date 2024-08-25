PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE _sqlx_migrations (
    version BIGINT PRIMARY KEY,
    description TEXT NOT NULL,
    installed_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN NOT NULL,
    checksum BLOB NOT NULL,
    execution_time BIGINT NOT NULL
);
INSERT INTO _sqlx_migrations VALUES(20230513205412,'init','2023-05-14 16:42:33',1,X'e9e4caf85fe8c0e9a2e04d4afae1cab14e5bbe5d974da22874acc02706296a1a00ff1815807e528397e004858bb0de24',4824622);
INSERT INTO _sqlx_migrations VALUES(20230514150322,'add-problems','2023-05-14 16:42:33',1,X'5c3cf5c925a45f24361bc57347be2ec1fcb74eafb15155df0b57ee09a978223049ef15c9fab8a9dedd2b84619dc9100f',7929907);
INSERT INTO _sqlx_migrations VALUES(20230526193511,'add-problem-skills','2023-05-26 19:57:40',1,X'0b735430e682f77735bcfed42b9763d18094a14c39f5e1852c4a823913f2980275cf05102d6b5778d190f3d5fce18256',8452850);
INSERT INTO _sqlx_migrations VALUES(20230528185942,'add-prerequisite-problems','2023-05-28 19:05:15',1,X'ec80d1a6265fb0d98ebf4aa171cb7b004f6cb8d373a0127cb3fdd9b31f5f83f6b776599a7a067b2f2145c5af7fe788dc',2086173);
INSERT INTO _sqlx_migrations VALUES(20230529002438,'add-problem-approaches','2023-05-29 17:18:40',1,X'9004402cea51f895e2c4072dcb7a3b95703b17c5868054ec7065053a30f05626d2574e7e352a2299f260edd4cad6a3a6',3312604);
INSERT INTO _sqlx_migrations VALUES(20230603202029,'add-problem-queues','2023-06-03 21:01:18',1,X'2e81ecb0cfa4a49815fd977daa7f05688d91e35fc371c83b27abb7c1b1cd7897a0e0be5789c8aecd42aaa7719ea084f2',2986046);
INSERT INTO _sqlx_migrations VALUES(20240825040820,'add-prereq-problems','2024-08-25 05:02:16',1,X'887541b86aba3b814e5914981a2aa2673acb171fe4838257fd26cbb6253381b68d4244578cddab566069ebd2e6fbbae6',7278491);
INSERT INTO _sqlx_migrations VALUES(20240825143407,'update-prereq-problems','2024-08-25 14:36:01',1,X'27349cf55c66b925ab8714d4faf8fa93b0f7eb4ea3094e6cbe628bc55fd3c49fcbcd7dc47b4858d2e8c6cb94aab86744',2928689);
INSERT INTO _sqlx_migrations VALUES(20240825201852,'update-skills','2024-08-25 20:20:53',1,X'471f4ccdec2a0fd04237eb8db2bb09041c41587b93aaf541258fe12a8e22966a18c46c99d246a12c34faae09c4b8c422',2243158);
CREATE TABLE skills (id primary key, summary text not null, description text);
INSERT INTO skills VALUES('c21e18ae-951a-4d8f-984a-cff1f03a8906','Computing the length of the opposite side of a right triangle from the length of the adjacent side and the angle between the adjacent side and the hypotenuse',NULL);
INSERT INTO skills VALUES('6253e17f-b44e-4d80-ac2a-db4474ca6cc8','Measuring angles using degrees',NULL);
INSERT INTO skills VALUES('dc5b0bef-4472-43d9-9252-6de96b71b68c','Subdividing circles into segments',NULL);
INSERT INTO skills VALUES('bb08e32d-5db5-49fc-97d1-9027bb2b6a29','Measuring in centimeters',NULL);
INSERT INTO skills VALUES('752c7a54-d89c-4298-9203-ea73a0866790','Computing the diameter of a circle from its radius',NULL);
INSERT INTO skills VALUES('d2d5b2bf-1c69-4879-a3f5-75ae65c484b7','Computing the radius of a circle from its circumference',NULL);
INSERT INTO skills VALUES('a1e29ba4-e514-4968-94e0-4a4f73c75701','Identifying the radius of a circle',NULL);
INSERT INTO skills VALUES('8c95f096-91aa-4d9e-a612-401d325becd4','Identifying the diameter of a circle',NULL);
INSERT INTO skills VALUES('54209a1a-ae03-4ff5-aa67-072873577406','Understanding the circumference of a circle',NULL);
INSERT INTO skills VALUES('5ec87192-2893-4981-9b1d-7456ae92af93','Understanding the length of a line',NULL);
INSERT INTO skills VALUES('909052bb-8d7d-4b90-86f5-ccc443140a18','Working with liters',NULL);
INSERT INTO skills VALUES('c7299bc0-8604-4469-bec7-c449ba1bf060','Ability to complete David Tolnay''s Rust Quiz without mistakes','You have demonstrated the knowledge needed to complete all of the David Tolnay''s [Rust Quiz](https://dtolnay.github.io/rust-quiz/) without making any mistakes.');
CREATE TABLE problems (
  id primary key,
  question_text text,
  question_url text,
  summary text not null,
  added_at datetime default current_timestamp
);
INSERT INTO problems VALUES('5f10b96b-7032-481b-84de-fd1d37a33cde','You are standing 10 meters away from the wall of a building and want to estimate its height.  You place one end of a stick on the ground and point the other to the top of the wall.  You see that the angle between the ground and the stick is 60 degrees.  Approximately how tall is the wall?',NULL,'Measuring the height of a building using the properties of right triangles','2024-08-25 22:54:50');
INSERT INTO problems VALUES('ef615296-bd68-4660-8ed8-f1056ce7c2bd','If you divide a circle into six equal segments, what is the angle of each segment in degrees?',NULL,'If you divide a circle into six equal segments, what is the angle of each segment in degrees?','2024-08-25 22:54:50');
INSERT INTO problems VALUES('8c91f5b7-9cf8-4ce2-8626-6756b0d85d52','What is the diameter of a circle whose radius is 5cm?',NULL,'What is the diameter of a circle whose radius is 5cm?','2024-08-25 22:54:50');
INSERT INTO problems VALUES('7de3e676-d23a-422c-8e9a-499398fb487e','What is the radius of a circle whose circumference is 20cm?',NULL,'What is the radius of a circle whose circumference is 20cm?','2024-08-25 22:54:50');
INSERT INTO problems VALUES('b0120309-5a11-4015-8d32-583dbf73ac7e','Which line in this diagram of a circle is the length of its radius?',NULL,'Which line in this diagram of a circle is the length of its radius?','2024-08-25 22:54:50');
INSERT INTO problems VALUES('ad306d13-9ef4-4f7e-94f8-7660570edd44','Which line in this diagram of a circle is the length of its diameter?',NULL,'Which line in this diagram of a circle is the length of its diameter?','2024-08-25 22:54:50');
INSERT INTO problems VALUES('bca284ca-3064-4bef-805c-c11a55a0ad93','Which line in this diagram of a circle is the length of its circumference?',NULL,'Which line in this diagram of a circle is the length of its circumference?','2024-08-25 22:54:50');
INSERT INTO problems VALUES('2e959eb0-fb53-4684-bc7c-29ccb9d3e3a1','A 1000 liter holding tank that catches runoff from some chemical process initially has 800 liters of water with 2 milliliters of pollution dissolved in it. Polluted water flows into the tank at a rate of 3 liters/hr and contains 5 milliliters/liter of pollution in it. A well mixed solution leaves the tank at 3 liters/hr as well. When the amount of pollution in the holding tank reaches 500 milliliters the inflow of polluted water is cut off and fresh water will enter the tank at a decreased rate of 2 liters/hr while the outflow is increased to 4 liters/hr. Determine the amount of pollution in the tank at any time t.',NULL,'Deriving a partial differential equation to model the amount of pollution in a tank of water','2024-08-25 22:54:50');
INSERT INTO problems VALUES('62bcfc08-c98e-4e29-9720-0847f856517d',replace('A 732 square feet apartment in Vienna had two bedrooms, a living room, a dining room, a toilet and washroom and a balcony. In 1971 rent was 700 schillings. What would the equivalent rent in euros be in 2022.  The euro wasn''t introduced until 2002. [Fill in remaining information needed to complete the calculation.]\n','\n',char(10)),NULL,'Calculate the 2022 rent in euros of an apartment in Vienna that was 700 schillings per month in 1971','2024-08-25 22:54:50');
INSERT INTO problems VALUES('ad6f42a7-45c2-4029-806f-5231cb3e9abb',NULL,'https://dtolnay.github.io/rust-quiz/1','Rust Quiz #1 from David Tolnay''s Rust Quiz','2024-08-25 22:54:51');
INSERT INTO problems VALUES('eab3c420-aece-4a84-abdd-a398a438242c',NULL,'https://dtolnay.github.io/rust-quiz/2','Rust Quiz #2 from David Tolnay''s Rust Quiz','2024-08-25 22:54:52');
INSERT INTO problems VALUES('f4e744ac-fc91-4527-bf41-0cb8077a1b5d',NULL,'https://dtolnay.github.io/rust-quiz/3','Rust Quiz #3 from David Tolnay''s Rust Quiz','2024-08-25 22:54:53');
INSERT INTO problems VALUES('359a50c7-0ad5-424d-8cb1-6396a5f7ece9',NULL,'https://dtolnay.github.io/rust-quiz/4','Rust Quiz #4 from David Tolnay''s Rust Quiz','2024-08-25 22:57:43');
INSERT INTO problems VALUES('d52fb8d8-acc6-4dd7-b724-b798abd52175',NULL,'https://dtolnay.github.io/rust-quiz/6','Rust Quiz #6 from David Tolnay''s Rust Quiz','2024-08-25 22:58:13');
INSERT INTO problems VALUES('34062c38-e57e-4dac-b653-b695e85863b3',NULL,'https://dtolnay.github.io/rust-quiz/8','Rust Quiz #8 from David Tolnay''s Rust Quiz','2024-08-25 22:58:34');
INSERT INTO problems VALUES('08bce113-d1b7-4c24-ba76-ce1a24613959',NULL,'https://dtolnay.github.io/rust-quiz/9','Rust Quiz#9 from David Tolnay''s Rust Quiz','2024-08-25 22:58:55');
INSERT INTO problems VALUES('3403caef-4fe4-4e6c-8bf2-28328ab3c86a',NULL,'https://dtolnay.github.io/rust-quiz/10','Rust Quiz #10 from David Tolnay''s Rust Quiz','2024-08-25 22:59:12');
INSERT INTO problems VALUES('d04a9901-bbb3-461d-8976-eaa52704c64a',NULL,'https://dtolnay.github.io/rust-quiz/11','Rust Quiz #11 from David Tolnay''s Rust Quiz','2024-08-25 22:59:30');
INSERT INTO problems VALUES('e0f53b73-0ae9-413b-bff3-884e73654960',NULL,'https://dtolnay.github.io/rust-quiz/12','Rust Quiz #12 from David Tolnay''s Rust Quiz','2024-08-25 22:59:47');
INSERT INTO problems VALUES('a987600c-c2a9-4087-9eef-20d4cdb4f471',NULL,'https://dtolnay.github.io/rust-quiz/13','Rust Quiz #13 from David Tolnay''s Rust Quiz','2024-08-25 23:00:08');
INSERT INTO problems VALUES('e0317968-b0bc-468f-86c0-4968b445aa23',NULL,'https://dtolnay.github.io/rust-quiz/14','Rust Quiz #14 from David Tolnay''s Rust Quiz','2024-08-25 23:00:25');
INSERT INTO problems VALUES('ff2760b1-aeb3-46f4-a092-8cae0da9be31',NULL,'https://dtolnay.github.io/rust-quiz/15','Rust Quiz #15 from David Tolnay''s Rust Quiz','2024-08-25 23:00:50');
INSERT INTO problems VALUES('328466c3-f22f-4ac5-baca-2f7089d4184a',NULL,'https://dtolnay.github.io/rust-quiz/16','Rust Quiz #16 from David Tolnay''s Rust Quiz','2024-08-25 23:03:16');
INSERT INTO problems VALUES('4c09e3e6-ce11-443e-82f9-26579204c773',NULL,'https://dtolnay.github.io/rust-quiz/17','Rust Quiz #17 from David Tolnay''s Rust Quiz','2024-08-25 23:03:39');
INSERT INTO problems VALUES('93a8dfbe-6fe0-4200-a2a1-9728c019938f',NULL,'https://dtolnay.github.io/rust-quiz/18','Rust Quiz #18 from David Tolnay''s Rust Quiz','2024-08-25 23:03:59');
INSERT INTO problems VALUES('990534d5-beb7-478e-bd95-30462c460ac1',NULL,'https://dtolnay.github.io/rust-quiz/19','Rust Quiz #19 from David Tolnay''s Rust Quiz','2024-08-25 23:04:18');
INSERT INTO problems VALUES('cc48c751-3aeb-433b-b88e-55191caa76a1',NULL,'https://dtolnay.github.io/rust-quiz/20','Rust Quiz #20 from David Tolnay''s Rust Quiz','2024-08-25 23:04:42');
INSERT INTO problems VALUES('74c10a2d-f2a9-4734-a66e-1b3a351bb0ac',NULL,'https://dtolnay.github.io/rust-quiz/21','Rust Quiz #21 from David Tolnay''s Rust Quiz','2024-08-25 23:05:00');
INSERT INTO problems VALUES('9b8c1918-95cb-4888-9a0e-f1f39c2367e9',NULL,'https://dtolnay.github.io/rust-quiz/22','Rust Quiz #22 from David Tolnay''s Rust Quiz','2024-08-25 23:05:18');
INSERT INTO problems VALUES('5cfe07b1-4363-40da-898f-4eb192c305bb',NULL,'https://dtolnay.github.io/rust-quiz/23','Rust Quiz #23 from David Tolnay''s Rust Quiz','2024-08-25 23:05:43');
INSERT INTO problems VALUES('9223e4e4-f0ef-434d-8e0b-74333c837d56',NULL,'https://dtolnay.github.io/rust-quiz/24','Rust Quiz #24 from David Tolnay''s Rust Quiz','2024-08-25 23:06:03');
INSERT INTO problems VALUES('0a35c3ac-32a1-4173-9c0f-9334001805e5',NULL,'https://dtolnay.github.io/rust-quiz/25','Rust Quiz #25 from David Tolnay''s Rust Quiz','2024-08-25 23:06:21');
INSERT INTO problems VALUES('9c607f1f-f6e2-4520-b282-4f5e4497d940',NULL,'https://dtolnay.github.io/rust-quiz/26','Rust Quiz #26 from David Tolnay''s Rust Quiz','2024-08-25 23:06:40');
INSERT INTO problems VALUES('0f345bd0-24eb-473a-90d3-5060b68f8884',NULL,'https://dtolnay.github.io/rust-quiz/27','Rust Quiz #27 from David Tolnay''s Rust Quiz','2024-08-25 23:06:58');
INSERT INTO problems VALUES('1f1bc291-feec-4baf-8af3-1308a18f6c29',NULL,'https://dtolnay.github.io/rust-quiz/28','Rust Quiz #28 from David Tolnay''s Rust Quiz','2024-08-25 23:07:20');
INSERT INTO problems VALUES('5f1e64f0-8e2f-4226-a7bb-24366991a20b',NULL,'https://dtolnay.github.io/rust-quiz/29','Rust Quiz #29 from David Tolnay''s Rust Quiz','2024-08-25 23:07:38');
INSERT INTO problems VALUES('28ea0c4a-5349-47dc-afe8-c4dab792e568',NULL,'https://dtolnay.github.io/rust-quiz/30','Rust Quiz #30 from David Tolnay''s Rust Quiz','2024-08-25 23:07:56');
INSERT INTO problems VALUES('3cd82009-1c9e-4e37-a46c-b58ffcf3b83d',NULL,'https://dtolnay.github.io/rust-quiz/31','Rust Quiz #31 from David Tolnay''s Rust Quiz','2024-08-25 23:08:14');
INSERT INTO problems VALUES('5b984244-6b8d-45c6-97a5-afde85d01cdf',NULL,'https://dtolnay.github.io/rust-quiz/32','Rust Quiz #32 from David Tolnay''s Rust Quiz','2024-08-25 23:08:35');
INSERT INTO problems VALUES('ea9e8f26-bef5-48a9-bd69-58ca4b17c97f',NULL,'https://dtolnay.github.io/rust-quiz/33','Rust Quiz #33 from David Tolnay''s Rust Quiz','2024-08-25 23:08:52');
INSERT INTO problems VALUES('19b83a23-8b2d-4596-a435-043483f37cc1',NULL,'https://dtolnay.github.io/rust-quiz/34','Rust Quiz #34 from David Tolnay''s Rust Quiz','2024-08-25 23:09:13');
INSERT INTO problems VALUES('eefd649a-66ee-4a34-9fcc-61a05fc910b5',NULL,'https://dtolnay.github.io/rust-quiz/35','Rust Quiz #35 from David Tolnay''s Rust Quiz','2024-08-25 23:09:30');
INSERT INTO problems VALUES('2c1c31c1-c8a6-4707-b4c7-211d911317df',NULL,'https://dtolnay.github.io/rust-quiz/36','Rust Quiz #36 from David Tolnay''s Rust Quiz','2024-08-25 23:09:52');
INSERT INTO problems VALUES('a500f40e-3448-4fee-8de7-06979fd57c35','This is a placeholder problem that requires mastery of David Tolnay''s Rust Quiz.  It is being made to test queues and the spaced repetition implementation.  Eventually perhaps it can be updated to become a real problem.',NULL,'A challenging Rust problem that requires mastery of David Tolnay''s Rust Quiz to complete','2024-08-25 23:12:53');
CREATE TABLE approaches (
  id text primary key,
  problem_id text not null,
  name text not null,
  "default" boolean not null default 1,
  foreign key(problem_id) references problems(id)
);
INSERT INTO approaches VALUES('eed2ab67-c579-4997-838e-599f9f69a025','2e959eb0-fb53-4684-bc7c-29ccb9d3e3a1','Derivation of a partial equation to model the system',1);
INSERT INTO approaches VALUES('e785d88d-e55e-4901-88d5-ee0841ce7e13','5f10b96b-7032-481b-84de-fd1d37a33cde','Default',1);
INSERT INTO approaches VALUES('566ee9de-f11e-4aac-9850-ee94aa1abea6','7de3e676-d23a-422c-8e9a-499398fb487e','Default',1);
INSERT INTO approaches VALUES('c1f78392-d7a2-46b0-a40a-7292d3b8e4ea','8c91f5b7-9cf8-4ce2-8626-6756b0d85d52','Multiplying by two',1);
INSERT INTO approaches VALUES('fd6e4065-74ce-4b48-bd8f-dd8634fb5b35','ad306d13-9ef4-4f7e-94f8-7660570edd44','Default',1);
INSERT INTO approaches VALUES('b38930a3-9bdf-45d7-89a3-861d1b727f1c','b0120309-5a11-4015-8d32-583dbf73ac7e','Default',1);
INSERT INTO approaches VALUES('a410aad8-5d4f-477d-b90d-74b1fdc3a6bd','bca284ca-3064-4bef-805c-c11a55a0ad93','Default',1);
INSERT INTO approaches VALUES('d8e6714e-2788-4e53-8a55-9a7acb4b470b','ef615296-bd68-4660-8ed8-f1056ce7c2bd','Subdividing by thirds',1);
INSERT INTO approaches VALUES('6e4c7350-4d67-4293-94c3-d5431b019537','7de3e676-d23a-422c-8e9a-499398fb487e','Another approach',1);
INSERT INTO approaches VALUES('a1d0bcbe-f9bb-47cc-995c-cc069ab1f18a','7de3e676-d23a-422c-8e9a-499398fb487e','A third way to do this problem',1);
CREATE TABLE prereq_skills (
  approach_id text not null,
  prereq_skill_id text not null,
  foreign key(approach_id) references approaches(id),
  foreign key(prereq_skill_id) references skills(id)
);
INSERT INTO prereq_skills VALUES('e785d88d-e55e-4901-88d5-ee0841ce7e13','c21e18ae-951a-4d8f-984a-cff1f03a8906');
INSERT INTO prereq_skills VALUES('e785d88d-e55e-4901-88d5-ee0841ce7e13','6253e17f-b44e-4d80-ac2a-db4474ca6cc8');
INSERT INTO prereq_skills VALUES('566ee9de-f11e-4aac-9850-ee94aa1abea6','d2d5b2bf-1c69-4879-a3f5-75ae65c484b7');
INSERT INTO prereq_skills VALUES('566ee9de-f11e-4aac-9850-ee94aa1abea6','bb08e32d-5db5-49fc-97d1-9027bb2b6a29');
INSERT INTO prereq_skills VALUES('a410aad8-5d4f-477d-b90d-74b1fdc3a6bd','54209a1a-ae03-4ff5-aa67-072873577406');
INSERT INTO prereq_skills VALUES('a410aad8-5d4f-477d-b90d-74b1fdc3a6bd','5ec87192-2893-4981-9b1d-7456ae92af93');
INSERT INTO prereq_skills VALUES('fd6e4065-74ce-4b48-bd8f-dd8634fb5b35','8c95f096-91aa-4d9e-a612-401d325becd4');
INSERT INTO prereq_skills VALUES('fd6e4065-74ce-4b48-bd8f-dd8634fb5b35','5ec87192-2893-4981-9b1d-7456ae92af93');
INSERT INTO prereq_skills VALUES('b38930a3-9bdf-45d7-89a3-861d1b727f1c','a1e29ba4-e514-4968-94e0-4a4f73c75701');
INSERT INTO prereq_skills VALUES('b38930a3-9bdf-45d7-89a3-861d1b727f1c','5ec87192-2893-4981-9b1d-7456ae92af93');
INSERT INTO prereq_skills VALUES('6e4c7350-4d67-4293-94c3-d5431b019537','6253e17f-b44e-4d80-ac2a-db4474ca6cc8');
INSERT INTO prereq_skills VALUES('a1d0bcbe-f9bb-47cc-995c-cc069ab1f18a','c21e18ae-951a-4d8f-984a-cff1f03a8906');
INSERT INTO prereq_skills VALUES('d8e6714e-2788-4e53-8a55-9a7acb4b470b','6253e17f-b44e-4d80-ac2a-db4474ca6cc8');
INSERT INTO prereq_skills VALUES('d8e6714e-2788-4e53-8a55-9a7acb4b470b','dc5b0bef-4472-43d9-9252-6de96b71b68c');
INSERT INTO prereq_skills VALUES('c1f78392-d7a2-46b0-a40a-7292d3b8e4ea','752c7a54-d89c-4298-9203-ea73a0866790');
INSERT INTO prereq_skills VALUES('c1f78392-d7a2-46b0-a40a-7292d3b8e4ea','bb08e32d-5db5-49fc-97d1-9027bb2b6a29');
INSERT INTO prereq_skills VALUES('eed2ab67-c579-4997-838e-599f9f69a025','909052bb-8d7d-4b90-86f5-ccc443140a18');
CREATE TABLE prereq_approaches (
  approach_id text not null,
  prereq_approach_id text not null,
  foreign key(approach_id) references approaches(id),
  foreign key(prereq_approach_id) references approaches(id)
);
INSERT INTO prereq_approaches VALUES('eed2ab67-c579-4997-838e-599f9f69a025','b38930a3-9bdf-45d7-89a3-861d1b727f1c');
CREATE TABLE users (
  created_at timestamp not null,
  id text primary key not null,
  updated_at timestamp not null default current_timestamp
);
INSERT INTO users VALUES('2023-06-03 21:01:18','04e229c9-795e-4f3a-a79e-ec18b5c28b99','2023-06-03 21:01:18');
CREATE TABLE queues (
  created_at timestamp not null,
  id text primary key not null,
  strategy integer not null default 1,
  summary text not null,
  target_problem_id text not null,
  updated_at timestamp not null default current_timestamp,
  user_id text not null,
  foreign key(target_problem_id) references problems(id),
  foreign key(user_id) references users(id)
);
INSERT INTO queues VALUES('2024-08-25T23:15:44.653485317+00:00','47b3fd8f-b0b2-45b3-af4b-368eb3ce140e',1,'Rust traits and function invocations','a500f40e-3448-4fee-8de7-06979fd57c35','2024-08-25T23:15:44.653485317+00:00','04e229c9-795e-4f3a-a79e-ec18b5c28b99');
CREATE TABLE answers (
  choice_id text not null,
  created_at timestamp not null,
  id text primary key not null,
  problem_id text not null,
  queue_id text not null,
  state integer not null,
  updated_at timestamp not null default current_timestamp,
  user_id text not null,
  foreign key(problem_id) references problems(id),
  foreign key(queue_id) references queues(id),
  foreign key(user_id) references users(id)
);
CREATE TABLE prereq_problems (
  skill_id text not null,
  prereq_problem_id text not null,
  prereq_approach_id text, added_at datetime default current_timestamp,
  foreign key(skill_id) references skills(id),
  foreign key(prereq_problem_id) references problems(id),
  foreign key(prereq_approach_id) references approaches(id)
);
INSERT INTO prereq_problems VALUES('c7299bc0-8604-4469-bec7-c449ba1bf060','b0120309-5a11-4015-8d32-583dbf73ac7e',NULL,'2024-08-25 18:59:45');
INSERT INTO prereq_problems VALUES('c7299bc0-8604-4469-bec7-c449ba1bf060','ad306d13-9ef4-4f7e-94f8-7660570edd44',NULL,'2024-08-25 19:34:12');
CREATE UNIQUE INDEX prereq_problems_uniq_idx on prereq_problems
  (skill_id, prereq_problem_id, ifnull(prereq_approach_id, 0));
COMMIT;
