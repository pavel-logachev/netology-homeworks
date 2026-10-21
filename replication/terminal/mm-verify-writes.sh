echo '=== Inputs already executed, sequentially on mm1/mm2 ==='
cat /master-master/sql/04-write-mm1.sql /master-master/sql/05-write-mm2.sql
cat /master-master/sql/06-write-mm1.sql /master-master/sql/07-write-mm2.sql
echo '=== Both nodes caught up (0 = success) ==='
wait_for mm1 mm2
wait_for mm2 mm1
echo '=== Visible on mm1 ==='
m mm1 -e 'SELECT * FROM circular_demo.messages ORDER BY id;'
echo '=== Visible on mm2 ==='
m mm2 -e 'SELECT * FROM circular_demo.messages ORDER BY id;'
