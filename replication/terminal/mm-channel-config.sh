echo '=== Executed channel setup inputs ==='
cat /master-master/sql/02-mm1.sql /master-master/sql/02-mm2.sql
echo '=== Executed schema input (mm1 only) ==='
cat /master-master/sql/03-schema-mm1.sql
wait_for mm1 mm2
wait_for mm2 mm1
