-- Task 5*: full result, all 599 customers, no LIMIT.
SELECT SUBSTRING_INDEX(email, '@', 1) AS email_local,
       SUBSTRING_INDEX(email, '@', -1) AS email_domain
FROM customer
ORDER BY customer_id;
