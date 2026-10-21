sql mm1 /master-master/sql/08-write-mm1.sql
wait_for mm1 mm2
m mm2 -e 'SELECT * FROM circular_demo.messages WHERE id=5;'
sql mm2 /master-master/sql/09-write-mm2.sql
wait_for mm2 mm1
m mm1 -e 'SELECT * FROM circular_demo.messages WHERE id=6;'
