param([Parameter(Mandatory=$true)][string]$TtydBinary)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
function DockerRun([string[]]$Arguments) {
  & docker @Arguments
  if ($LASTEXITCODE -ne 0) { throw "docker failed ($LASTEXITCODE): $Arguments" }
}
foreach($f in @('master-slave/docker-compose.yml','master-master/docker-compose.yml','docker-compose.evidence.yml')) {
  DockerRun @('compose','-f',$f,'config','--quiet')
}
# Initialize MySQL before enabling the replica's super_read_only setting.
foreach($f in @('master-slave/docker-compose.yml','master-master/docker-compose.yml')) {
  DockerRun @('compose','-f',$f,'up','-d','--wait','--wait-timeout','180')
}
foreach($n in @('master','replica','mm1','mm2')) {
  if ($n -in @('master','replica')) { $top='master-slave' } else { $top='master-master' }
  DockerRun @('cp',"$top/conf/$n.cnf","nt-repl-${n}:/etc/mysql/conf.d/replication.cnf")
  DockerRun @('exec',"nt-repl-$n",'chmod','444','/etc/mysql/conf.d/replication.cnf')
  DockerRun @('cp',"$top/sql","nt-repl-${n}:/lab-sql")
}
DockerRun @('restart','nt-repl-master','nt-repl-replica','nt-repl-mm1','nt-repl-mm2')
foreach($f in @('master-slave/docker-compose.yml','master-master/docker-compose.yml')) {
  DockerRun @('compose','-f',$f,'up','-d','--wait','--wait-timeout','120')
}
DockerRun @('compose','-f','docker-compose.evidence.yml','create')
DockerRun @('cp',$TtydBinary,'nt-repl-client:/usr/local/bin/ttyd')
DockerRun @('exec','nt-repl-master','true')
DockerRun @('cp','terminal','nt-repl-client:/terminal')
# Copy only inputs, never the evidence directory.
DockerRun @('cp','master-slave','nt-repl-client:/master-slave')
DockerRun @('cp','master-master','nt-repl-client:/master-master')
DockerRun @('compose','-f','docker-compose.evidence.yml','start')
DockerRun @('exec','nt-repl-client','mkdir','-p','/captures','/etc/mysql/conf.d/master-slave','/etc/mysql/conf.d/master-master')
DockerRun @('cp','master-slave/conf/.','nt-repl-client:/etc/mysql/conf.d/master-slave/')
DockerRun @('cp','master-master/conf/.','nt-repl-client:/etc/mysql/conf.d/master-master/')
DockerRun @('exec','nt-repl-client','chmod','-R','a-w','/etc/mysql/conf.d/master-slave','/etc/mysql/conf.d/master-master')
