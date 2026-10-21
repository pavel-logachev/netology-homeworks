$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$utf8=New-Object System.Text.UTF8Encoding($false)
$all=New-Object System.Collections.Generic.List[string]
function Query($node,$query) {
  $out = & docker exec -e MYSQL_PWD=nt-repl-lab-only "nt-repl-$node" mysql -uroot --batch --raw -e $query 2>&1
  if($LASTEXITCODE -ne 0) { throw "Query failed on ${node}: $out" }
  $text=$out -join "`n"
  $all.Add("=== $node | $query ===`n$text")
  return $text
}
foreach($n in @('master','replica','mm1','mm2')) {
  $null=Query $n 'SELECT @@hostname,@@version,@@server_id,@@server_uuid,@@read_only,@@super_read_only,@@log_bin,@@binlog_format,@@gtid_mode,@@enforce_gtid_consistency,@@auto_increment_increment,@@auto_increment_offset,@@GLOBAL.gtid_executed;'
  $config = & docker exec "nt-repl-$n" bash -c 'cat /etc/mysql/conf.d/*.cnf'
  if($LASTEXITCODE -ne 0) {throw 'cat failed'}
  $all.Add("=== $n | cat /etc/mysql/conf.d/*.cnf ===`n"+($config -join "`n"))
  if($n -in @('master','replica')){$top='master-slave'}else{$top='master-master'}
  $local=(Get-Content "$top/conf/$n.cnf" -Raw).Trim()
  if(($config -join "`n").Trim() -ne $local) {throw "config mismatch $n"}
  if($n -ne 'master') {
    $status=Query $n 'SHOW REPLICA STATUS\G'
    foreach($match in @('Replica_IO_Running: Yes','Replica_SQL_Running: Yes','Last_IO_Errno: 0','Last_SQL_Errno: 0','Auto_Position: 1')) {
      if(-not $status.Contains($match)) {throw "Status missing ${match}: $n"}
    }
    [IO.File]::WriteAllText((Join-Path $PSScriptRoot "evidence/full-status-$n.txt"),$status,$utf8)
  }
  $null=Query $n 'SHOW MASTER STATUS\G'
}
$master=Query master 'SELECT * FROM replication_demo.messages ORDER BY id;'
$replica=Query replica 'SELECT * FROM replication_demo.messages ORDER BY id;'
if($master -ne $replica){throw 'Master/replica row mismatch'}
$mm1=Query mm1 'SELECT * FROM circular_demo.messages ORDER BY id;'
$mm2=Query mm2 'SELECT * FROM circular_demo.messages ORDER BY id;'
if($mm1 -ne $mm2){throw 'mm row mismatch'}
foreach($line in @("1`tmm1`tfirst odd id","2`tmm2`tfirst even id","3`tmm1`tsecond odd id","4`tmm2`tsecond even id","5`tmm1`tthird odd id","6`tmm2`tthird even id")) {
 if(-not $mm1.Contains($line)){throw "Missing row $line"}
}
$ro=Query replica 'SELECT @@read_only,@@super_read_only;'
if(-not $ro.Contains("1`t1")){throw 'Replica not read only'}
$all.Add('PASS: config files identical to host inputs; all replication channels Yes/Yes, zero error numbers and Auto_Position=1; master/replica data equal; circular data equal with ids 1,2,3,4,5,6; replica read_only/super_read_only=1/1.')
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'evidence/assertions.txt'),($all -join "`n`n"),$utf8)
Write-Output $all[$all.Count-1]
