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
CREATE TABLE skills (
  id primary key,
  description text
);
INSERT INTO skills VALUES('c21e18ae-951a-4d8f-984a-cff1f03a8906','Computing the length of the opposite side of a right triangle from the length of the adjacent side and the angle between the adjacent side and the hypotenuse');
INSERT INTO skills VALUES('6253e17f-b44e-4d80-ac2a-db4474ca6cc8','Measuring angles using degrees');
INSERT INTO skills VALUES('dc5b0bef-4472-43d9-9252-6de96b71b68c','Subdividing circles into segments');
INSERT INTO skills VALUES('bb08e32d-5db5-49fc-97d1-9027bb2b6a29','Measuring in centimeters');
INSERT INTO skills VALUES('752c7a54-d89c-4298-9203-ea73a0866790','Computing the diameter of a circle from its radius');
INSERT INTO skills VALUES('d2d5b2bf-1c69-4879-a3f5-75ae65c484b7','Computing the radius of a circle from its circumference');
INSERT INTO skills VALUES('a1e29ba4-e514-4968-94e0-4a4f73c75701','Identifying the radius of a circle');
INSERT INTO skills VALUES('8c95f096-91aa-4d9e-a612-401d325becd4','Identifying the diameter of a circle');
INSERT INTO skills VALUES('54209a1a-ae03-4ff5-aa67-072873577406','Understanding the circumference of a circle');
INSERT INTO skills VALUES('5ec87192-2893-4981-9b1d-7456ae92af93','Understanding the length of a line');
INSERT INTO skills VALUES('909052bb-8d7d-4b90-86f5-ccc443140a18','Working with liters');
CREATE TABLE problems (
  id primary key,
  description text
);
INSERT INTO problems VALUES('5f10b96b-7032-481b-84de-fd1d37a33cde','You are standing 10 meters away from the wall of a building and want to estimate its height.  You place one end of a stick on the ground and point the other to the top of the wall.  You see that the angle between the ground and the stick is 60 degrees.  Approximately how tall is the wall?');
INSERT INTO problems VALUES('ef615296-bd68-4660-8ed8-f1056ce7c2bd','If you divide a circle into six equal segments, what is the angle of each segment in degrees?');
INSERT INTO problems VALUES('8c91f5b7-9cf8-4ce2-8626-6756b0d85d52','What is the diameter of a circle whose radius is 5cm?');
INSERT INTO problems VALUES('7de3e676-d23a-422c-8e9a-499398fb487e','What is the radius of a circle whose circumference is 20cm?');
INSERT INTO problems VALUES('b0120309-5a11-4015-8d32-583dbf73ac7e','Which line in this diagram of a circle is the length of its radius?');
INSERT INTO problems VALUES('ad306d13-9ef4-4f7e-94f8-7660570edd44','Which line in this diagram of a circle is the length of its diameter?');
INSERT INTO problems VALUES('bca284ca-3064-4bef-805c-c11a55a0ad93','Which line in this diagram of a circle is the length of its circumference?');
INSERT INTO problems VALUES('2e959eb0-fb53-4684-bc7c-29ccb9d3e3a1','A 1000 liter holding tank that catches runoff from some chemical process initially has 800 liters of water with 2 milliliters of pollution dissolved in it. Polluted water flows into the tank at a rate of 3 liters/hr and contains 5 milliliters/liter of pollution in it. A well mixed solution leaves the tank at 3 liters/hr as well. When the amount of pollution in the holding tank reaches 500 milliliters the inflow of polluted water is cut off and fresh water will enter the tank at a decreased rate of 2 liters/hr while the outflow is increased to 4 liters/hr. Determine the amount of pollution in the tank at any time t.');
CREATE TABLE IF NOT EXISTS "prerequisite_skills" (
  problem_id text not null,
  skill_id text not null,
  foreign key(problem_id) references problems(id),
  foreign key(skill_id) references skills(id)
);
INSERT INTO prerequisite_skills VALUES('5f10b96b-7032-481b-84de-fd1d37a33cde','c21e18ae-951a-4d8f-984a-cff1f03a8906');
INSERT INTO prerequisite_skills VALUES('5f10b96b-7032-481b-84de-fd1d37a33cde','6253e17f-b44e-4d80-ac2a-db4474ca6cc8');
INSERT INTO prerequisite_skills VALUES('ef615296-bd68-4660-8ed8-f1056ce7c2bd','6253e17f-b44e-4d80-ac2a-db4474ca6cc8');
INSERT INTO prerequisite_skills VALUES('ef615296-bd68-4660-8ed8-f1056ce7c2bd','dc5b0bef-4472-43d9-9252-6de96b71b68c');
INSERT INTO prerequisite_skills VALUES('8c91f5b7-9cf8-4ce2-8626-6756b0d85d52','752c7a54-d89c-4298-9203-ea73a0866790');
INSERT INTO prerequisite_skills VALUES('8c91f5b7-9cf8-4ce2-8626-6756b0d85d52','bb08e32d-5db5-49fc-97d1-9027bb2b6a29');
INSERT INTO prerequisite_skills VALUES('7de3e676-d23a-422c-8e9a-499398fb487e','d2d5b2bf-1c69-4879-a3f5-75ae65c484b7');
INSERT INTO prerequisite_skills VALUES('7de3e676-d23a-422c-8e9a-499398fb487e','bb08e32d-5db5-49fc-97d1-9027bb2b6a29');
INSERT INTO prerequisite_skills VALUES('bca284ca-3064-4bef-805c-c11a55a0ad93','54209a1a-ae03-4ff5-aa67-072873577406');
INSERT INTO prerequisite_skills VALUES('bca284ca-3064-4bef-805c-c11a55a0ad93','5ec87192-2893-4981-9b1d-7456ae92af93');
INSERT INTO prerequisite_skills VALUES('ad306d13-9ef4-4f7e-94f8-7660570edd44','8c95f096-91aa-4d9e-a612-401d325becd4');
INSERT INTO prerequisite_skills VALUES('ad306d13-9ef4-4f7e-94f8-7660570edd44','5ec87192-2893-4981-9b1d-7456ae92af93');
INSERT INTO prerequisite_skills VALUES('b0120309-5a11-4015-8d32-583dbf73ac7e','a1e29ba4-e514-4968-94e0-4a4f73c75701');
INSERT INTO prerequisite_skills VALUES('b0120309-5a11-4015-8d32-583dbf73ac7e','5ec87192-2893-4981-9b1d-7456ae92af93');
INSERT INTO prerequisite_skills VALUES('2e959eb0-fb53-4684-bc7c-29ccb9d3e3a1','909052bb-8d7d-4b90-86f5-ccc443140a18');
CREATE TABLE prerequisite_problems (
  problem_id text not null,
  prerequisite_problem_id text not null,
  foreign key(problem_id) references problems(id),
  foreign key(prerequisite_problem_id) references problems(id)
);
COMMIT;
