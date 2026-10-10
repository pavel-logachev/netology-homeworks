-- Screenshot preview only; full query in 05-email-split.sql.
SELECT SUBSTRING_INDEX(email, '@', 1) AS email_local,
       SUBSTRING_INDEX(email, '@', -1) AS email_domain
FROM customer
ORDER BY customer_id
LIMIT 10;
