-- Task 3*: execute as root. Partial revokes permit schema exclusions
-- from global grants; ordinary database-level REVOKE would not suffice.
SET PERSIST partial_revokes = ON;
REVOKE INSERT, UPDATE, DELETE ON sakila.* FROM 'sys_temp'@'localhost';
SHOW GRANTS FOR 'sys_temp'@'localhost'\G
SELECT @@GLOBAL.partial_revokes AS partial_revokes;
