INSERT INTO circular_demo.messages(origin,message) VALUES ('mm2','first even id');
SELECT LAST_INSERT_ID() AS generated_on_mm2;
