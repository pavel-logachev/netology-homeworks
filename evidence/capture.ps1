. 'C:\Users\pavel\Documents\DeepSeekHarness\cache\netology-20261107\w-1301\lab.ps1'
$Target='172.24.0.2'
foreach ($mode in @('syn','fin','xmas','udp')) {
 $option=@{syn='-sS';fin='-sF';xmas='-sX';udp='-sU'}[$mode]
 $ports=if ($mode -eq 'udp') {'53,69,111,137,161,65000'} else {'21,22,80,445,65000'}
 D -A @('exec','-d','nt1301-capture','sh','-c',"tcpdump -i eth0 -U -nn -w /evidence/$mode.pcap 'host $Target and (tcp or udp or icmp)' > /evidence/$mode-capture.txt 2>&1 & echo `$! > /tmp/nt1301-capture.pid; wait")
 D -A @('exec','nt1301-capture','sh','-c',"for i in 1 2 3 4 5; do test -s /evidence/$mode.pcap && exit 0; sleep 1; done; exit 1")
 D -A @('exec','nt1301-scanner','nmap',$option,'-n','-Pn','--reason','-p',$ports,'--max-retries','1','--host-timeout','90s','-T3','-oA',"/evidence/$mode",$Target) -Log "$mode-console.txt"
 D -A @('exec','nt1301-capture','sh','-c','kill -INT $(cat /tmp/nt1301-capture.pid); for i in 1 2 3 4 5; do kill -0 $(cat /tmp/nt1301-capture.pid) 2>/dev/null || exit 0; sleep 1; done; exit 1')
 D -A @('exec','nt1301-capture','tshark','-r',"/evidence/$mode.pcap",'-n') -Log "$mode-tshark.txt"
 D -A @('exec','nt1301-capture','capinfos',"/evidence/$mode.pcap") -Log "$mode-capinfos.txt"
}
D -A @('cp',"$Root\analyze.sh",'nt1301-capture:/tmp/nt1301-analyze.sh')
D -A @('exec','nt1301-capture','sh','/tmp/nt1301-analyze.sh') -Log 'analysis-console.txt'
