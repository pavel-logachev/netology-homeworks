CREATE DATABASE circular_demo;
CREATE TABLE circular_demo.messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  origin VARCHAR(32) NOT NULL,
  message VARCHAR(100) NOT NULL
) ENGINE=InnoDB;
