. 'C:\Users\pavel\Documents\DeepSeekHarness\cache\netology-20261107\w-1301\lab.ps1'
D -A @('inspect','nt1301-target','nt1301-scanner','nt1301-capture','--format','{{.Name}} network={{.HostConfig.NetworkMode}} ports={{json .HostConfig.PortBindings}} mounts={{json .Mounts}}') -Log 'cleanup.txt'
D -A @('rm','-f','nt1301-capture','nt1301-scanner','nt1301-target') -Log 'cleanup.txt'
D -A @('network','rm','nt1301-lab') -Log 'cleanup.txt'
[IO.File]::AppendAllText("$Evidence\cleanup.txt", "`ndocker ps -a --filter name=nt1301-`n", (New-Object Text.UTF8Encoding $false))
D -A @('ps','-a','--filter','name=nt1301-') -Log 'cleanup.txt'
[IO.File]::AppendAllText("$Evidence\cleanup.txt", "`ndocker network ls --filter name=nt1301-`n", (New-Object Text.UTF8Encoding $false))
D -A @('network','ls','--filter','name=nt1301-') -Log 'cleanup.txt'
$leftC=@(& docker ps -aq --filter name=nt1301-)
$leftN=@(& docker network ls -q --filter name=nt1301-)
if ($leftC.Count -or $leftN.Count) { throw 'Owned Docker objects remain' }
[IO.File]::AppendAllText("$Evidence\cleanup.txt", "PASS remaining nt1301 containers=0 networks=0`n", (New-Object Text.UTF8Encoding $false))
