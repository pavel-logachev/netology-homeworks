-- Screenshot preview only; full query in 06-email-capitalize.sql.
WITH email_parts AS (
  SELECT customer_id, SUBSTRING_INDEX(email, '@', 1) AS email_local,
         SUBSTRING_INDEX(email, '@', -1) AS email_domain
  FROM customer
)
SELECT CONCAT(UPPER(LEFT(email_local, 1)),
              LOWER(SUBSTRING(email_local, 2))) AS email_local,
       CONCAT(UPPER(LEFT(email_domain, 1)),
              LOWER(SUBSTRING(email_domain, 2))) AS email_domain
FROM email_parts
ORDER BY customer_id
LIMIT 10;
