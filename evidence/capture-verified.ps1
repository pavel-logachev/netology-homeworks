. 'C:\Users\pavel\Documents\DeepSeekHarness\cache\netology-20261107\w-1301\lab.ps1'
New-Item -ItemType Directory -Path "$Evidence\verified" -Force | Out-Null
foreach ($mode in @('syn','fin','xmas','udp')) {
 $option=@{syn='-sS';fin='-sF';xmas='-sX';udp='-sU'}[$mode]
 $ports=if ($mode -eq 'udp') {'53,69,111,137,161,65000'} else {'21,22,80,445,65000'}
 D -A @('exec','-d','nt1301-capture','sh','-c',"tcpdump --immediate-mode -i eth0 -U -nn -w /evidence/verified/$mode.pcap 'host 172.24.0.2 and host 172.24.0.3 and (tcp or udp or icmp)' > /evidence/verified/$mode-capture.txt 2>&1 & echo `$! > /tmp/nt1301-capture.pid; wait")
 D -A @('exec','nt1301-capture','sh','-c',"for i in 1 2 3 4 5; do test -s /evidence/verified/$mode.pcap && exit 0; sleep 1; done; exit 1")
 D -A @('exec','nt1301-scanner','nmap',$option,'-n','-Pn','--reason','-p',$ports,'--max-retries','1','--host-timeout','90s','-T3','-oA',"/evidence/verified/$mode",'172.24.0.2') -Log "verified/$mode-console.txt"
 D -A @('exec','nt1301-capture','sh','-c','sleep 1; kill -INT $(cat /tmp/nt1301-capture.pid); for i in 1 2 3 4 5; do kill -0 $(cat /tmp/nt1301-capture.pid) 2>/dev/null || exit 0; sleep 1; done; exit 1')
 D -A @('exec','nt1301-capture','tshark','-r',"/evidence/verified/$mode.pcap",'-n') -Log "verified/$mode-tshark.txt"
 D -A @('exec','nt1301-capture','capinfos',"/evidence/verified/$mode.pcap") -Log "verified/$mode-capinfos.txt"
}
D -A @('cp',"$Root\analyze.sh",'nt1301-capture:/tmp/nt1301-analyze-verified.sh')
D -A @('exec','nt1301-capture','sh','/tmp/nt1301-analyze-verified.sh') -Log 'verified/analysis-console.txt'
