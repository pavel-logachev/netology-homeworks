INSERT INTO circular_demo.messages(origin,message) VALUES ('mm1','first odd id');
SELECT LAST_INSERT_ID() AS generated_on_mm1;
