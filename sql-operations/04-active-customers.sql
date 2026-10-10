-- Task 4: one query, active Kelly/Willie, lower case and ll -> pp in names.
SELECT LOWER(last_name) AS last_name,
       REPLACE(LOWER(first_name), 'll', 'pp') AS first_name
FROM customer
WHERE active = 1 AND first_name IN ('Kelly', 'Willie')
ORDER BY last_name, first_name;
