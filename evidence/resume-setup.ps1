. 'C:\Users\pavel\Documents\DeepSeekHarness\cache\netology-20261107\w-1301\lab.ps1'
D -A @('exec','nt1301-target','sh','-c','ps aux; netstat -lntup') -Log 'startup-diagnostic.txt'
D -A @('exec','nt1301-target','sh','-c','/bin/services.sh') -Log 'services-start.txt' -AllowFailure
D -A @('run','-d','--name','nt1301-scanner','--hostname','nt1301-scanner','--network','nt1301-lab','--mount',"type=bind,source=$Evidence,target=/evidence",'--cap-add','NET_RAW','--cap-add','NET_ADMIN','nicolaka/netshoot:latest','sleep','infinity') -Log 'setup.txt'
D -A @('exec','nt1301-scanner','sh','-c','nmap --version; tshark --version; tcpdump --version; ip -4 addr; ip route') -Log 'tools.txt'
D -A @('exec','nt1301-target','sh','-c','netstat -lntup; /usr/sbin/smbd -V; grep -i "username map script" /etc/samba/smb.conf') -Log 'target-ready.txt'
D -A @('network','inspect','nt1301-lab') -Log 'network.json'
D -A @('inspect','nt1301-target','nt1301-scanner') -Log 'containers.json'
