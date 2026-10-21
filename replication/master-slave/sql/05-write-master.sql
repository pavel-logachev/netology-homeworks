INSERT INTO replication_demo.messages(origin,message) VALUES ('master','Live terminal check');
SELECT LAST_INSERT_ID() AS generated_on_master;
