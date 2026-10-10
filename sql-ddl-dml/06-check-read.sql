-- Reconnect as sys_temp: reads still work after schema DML exclusions.
SELECT CURRENT_USER() AS authenticated_as, COUNT(*) AS customers FROM sakila.customer;
