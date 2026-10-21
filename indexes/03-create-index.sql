CREATE INDEX idx_hw1205_payment_date_amount ON payment (payment_date, amount);
ANALYZE TABLE payment;
SHOW INDEX FROM payment WHERE Key_name = 'idx_hw1205_payment_date_amount';
