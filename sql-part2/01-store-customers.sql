SELECT s.store_id, st.last_name, st.first_name, ci.city,
       cc.customer_count
FROM store AS s
JOIN (SELECT store_id, COUNT(*) AS customer_count
      FROM customer GROUP BY store_id HAVING COUNT(*) > 300) AS cc
  ON cc.store_id = s.store_id
JOIN staff AS st ON st.store_id = s.store_id
JOIN address AS a ON a.address_id = s.address_id
JOIN city AS ci ON ci.city_id = a.city_id
ORDER BY s.store_id, st.staff_id;
