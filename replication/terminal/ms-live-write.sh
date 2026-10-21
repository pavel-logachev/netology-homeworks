sql master /master-slave/sql/05-write-master.sql
wait_for master replica
m master -e 'SELECT * FROM replication_demo.messages ORDER BY id;'
m replica -e 'SELECT * FROM replication_demo.messages ORDER BY id;'
