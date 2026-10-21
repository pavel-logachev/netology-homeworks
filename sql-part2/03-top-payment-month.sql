WITH monthly_payments AS (
  SELECT CAST(DATE_FORMAT(payment_date, '%Y-%m-01') AS DATE) AS month_start,
         SUM(amount) AS total_amount
  FROM payment GROUP BY month_start
), ranked AS (
  SELECT month_start, total_amount,
         DENSE_RANK() OVER (ORDER BY total_amount DESC) AS revenue_rank
  FROM monthly_payments
)
SELECT DATE_FORMAT(m.month_start, '%Y-%m') AS payment_month,
       m.total_amount,
       (SELECT COUNT(*) FROM rental AS r
        WHERE r.rental_date >= m.month_start
          AND r.rental_date < m.month_start + INTERVAL 1 MONTH) AS rentals
FROM ranked AS m WHERE m.revenue_rank = 1
ORDER BY m.month_start;
