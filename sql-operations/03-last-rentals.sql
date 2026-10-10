-- Task 3: five latest rentals; ID resolves equal-date ties deterministically.
SELECT rental_id, rental_date, inventory_id, customer_id, return_date, staff_id
FROM rental
ORDER BY rental_date DESC, rental_id DESC
LIMIT 5;
