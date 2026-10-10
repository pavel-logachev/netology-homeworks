-- Run as sys_temp with mysql --force. Expected ERROR 1142 for each
-- command. These no-op predicates avoid modifying data even if grants fail.
INSERT INTO sakila.customer (store_id, first_name, last_name, address_id)
SELECT 1, 'CHECK', 'NOOP', 1 WHERE FALSE;
UPDATE sakila.customer SET first_name = first_name WHERE FALSE;
DELETE FROM sakila.customer WHERE FALSE;
