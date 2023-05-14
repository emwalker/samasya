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
CREATE TABLE skills (
  id primary key,
  description text
);
INSERT INTO skills VALUES('430eb2cb-6731-4d7b-ae9a-d75859283c19','This is a new skill');
INSERT INTO skills VALUES('ca98fa11-7968-42c6-b0ba-708c2cff660b','Another new skill');
INSERT INTO skills VALUES('a67c1a21-c047-40a5-b49e-02006d067b98','Mathematics, statistics and logical reasoning');
INSERT INTO skills VALUES('12f37027-d1c1-4107-a4c5-ad49b6c56668','This is the fifth skill');
CREATE TABLE problems (
  id primary key,
  description text
);
INSERT INTO problems VALUES('d02d80e4-f74e-4075-b2a4-1934f8f36e03','You''re trying to decide between planting corn now and waiting two weeks.');
INSERT INTO problems VALUES('7b21dc01-dbec-45ac-9be1-3a4a1b0e49da','In another case, there has been a brief rain spell.');
COMMIT;
