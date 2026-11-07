import fs from 'node:fs';import crypto from 'node:crypto';import path from 'node:path';
const root='C:/Users/pavel/Documents/DeepSeekHarness/cache/netology-20261107/w-1301';const ev=root+'/wt/evidence';
fs.copyFileSync(root+'/inventory.mjs',ev+'/inventory.mjs');
const walk=(dir,prefix='')=>fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(dir+'/'+e.name,prefix+e.name+'/'):[prefix+e.name]);
const role=n=>{
 if(n.endsWith('.pcap'))return 'Canonical original packet capture';
 if(n.endsWith('.png'))return 'Real-output terminal screenshot, visually inspected with read_image';
 if(n.endsWith('-fields.txt'))return 'Frame-numbered fields (IPv4 may include quoted nested headers)';
 if(n.endsWith('-tshark.txt'))return 'Readable tshark packet summary';
 if(n.endsWith('-capinfos.txt'))return 'Packet count, capture metadata, pcap SHA256';
 if(n.endsWith('-capture.txt'))return 'tcpdump capture/received/drop statistics';
 if(n.endsWith('-tshark-stderr.txt'))return 'Tshark diagnostic stderr (empty if clean)';
 if(n.endsWith('.xml'))return 'Nmap machine-readable scan results and exact invocation';
 if(n.endsWith('.gnmap'))return 'Nmap grepable scan output';
 if(n.endsWith('.nmap'))return 'Nmap human-readable scan output';
 if(n.endsWith('-console.txt'))return 'Raw console output of named phase';
 if(/\.(ps1|sh|mjs)$/.test(n))return 'Exact host/container execution or evidence-generation script';
 return ({'commands.txt':'Timestamped Docker commands, output and exit codes, includes superseded first attempts','preflight.txt':'Host, Docker version, branch and initial prefix listings','images.jsonl':'Image inspection tags, IDs and RepoDigests','target-before.txt':'Original startup script, kernel, issue and initial listeners','startup-diagnostic.txt':'Diagnostic process/listener snapshot after stderr interruption','services-start.txt':'Service startup warnings and outputs','tools.txt':'Nmap/tshark/tcpdump versions and scanner IP/routes','target-ready.txt':'Listening ports and Samba binary version','source-confirmed.txt':'Successful DSH HTTP200 EDB title/version/description quotations','network.json':'Internal bridge network, subnet and owned IP addresses','containers.json':'Container configuration, no published ports and limited bind mounts','version-details.txt':'Effective Samba option and local Unreal/distccd binary versions','pulls.txt':'Pull digest receipt transcribed from successful job','packages-and-samba.txt':'Package versions and effective Samba configuration','capture-notes.txt':'Canonical capture location and superseded-attempt cautions','independent-check.txt':'Independent byte-parser packet and image checks, failures0','cleanup.txt':'Exact owned-object deletion outputs and empty final listings','command-appendix.md':'Host/source/browser commands outside Docker logger','verified/traffic-counts.txt':'Final exact tshark filters and counts','file-inventory.txt':'This inventory','sha256.txt':'SHA256 of all evidence files except itself'})[n]||'Raw named-phase evidence';
};
let names=walk(ev).filter(n=>!['file-inventory.txt','sha256.txt'].includes(n)).sort();
fs.writeFileSync(ev+'/file-inventory.txt',names.map(n=>`${n}\t${fs.statSync(ev+'/'+n).size} bytes\t${role(n)}`).join('\n')+'\nfile-inventory.txt\tInventory\nsha256.txt\tSHA256 manifest excludes itself\n');
names=walk(ev).filter(n=>n!=='sha256.txt').sort();
fs.writeFileSync(ev+'/sha256.txt',names.map(n=>crypto.createHash('sha256').update(fs.readFileSync(ev+'/'+n)).digest('hex')+'  '+n).join('\n')+'\n');
const highRisk=/-----BEGIN (?:RSA |OPENSSH |EC )?PRIVATE KEY-----|\bgh[pousr]_[A-Za-z0-9]{25,}|\bsk-[A-Za-z0-9]{25,}|\bAKIA[A-Z0-9]{16}/;
let flagged=[];for(const n of names.filter(n=>!n.endsWith('.pcap')&&!n.endsWith('.png'))){if(highRisk.test(fs.readFileSync(ev+'/'+n,'utf8')))flagged.push(n);}
console.log('Evidence files='+walk(ev).length+'; pcaps='+names.filter(n=>n.endsWith('.pcap')).length+'; PNGs='+names.filter(n=>n.endsWith('.png')).length+'; high-risk secret pattern matches='+flagged.length);
if(flagged.length){console.log('Inspect files (values not printed): '+flagged.join(', '));process.exitCode=1;}
