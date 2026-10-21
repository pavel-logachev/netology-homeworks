SELECT COUNT(*) AS films_above_average,
       (SELECT AVG(length) FROM film) AS average_length_minutes
FROM film WHERE length > (SELECT AVG(length) FROM film);
