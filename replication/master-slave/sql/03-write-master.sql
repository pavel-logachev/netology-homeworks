CREATE DATABASE replication_demo;
CREATE TABLE replication_demo.messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  origin VARCHAR(32) NOT NULL,
  message VARCHAR(100) NOT NULL
) ENGINE=InnoDB;
INSERT INTO replication_demo.messages(origin,message)
VALUES ('master','Hello from Pavel Logachev'),('master','GTID replication works');
SELECT * FROM replication_demo.messages ORDER BY id;
