-- Expected: ERROR 1290 (HY000), super-read-only prevents this write even for root.
INSERT INTO replication_demo.messages(origin,message) VALUES ('replica','must fail');
