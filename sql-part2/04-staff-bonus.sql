SELECT s.staff_id, s.last_name, s.first_name,
       COUNT(p.payment_id) AS sales_count,
       CASE WHEN COUNT(p.payment_id) > 8000 THEN 'Да' ELSE 'Нет' END AS Премия
FROM staff AS s LEFT JOIN payment AS p ON p.staff_id = s.staff_id
GROUP BY s.staff_id, s.last_name, s.first_name
ORDER BY s.staff_id;
