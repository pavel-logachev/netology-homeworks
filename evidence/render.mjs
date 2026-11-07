import fs from 'node:fs';
const root='C:/Users/pavel/Documents/DeepSeekHarness/cache/netology-20261107/w-1301';
const ev=root+'/wt/evidence';
const read=p=>fs.readFileSync(ev+'/'+p,'utf8').replace(/^\uFEFF/,'').trim();
const esc=s=>s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
const service=read('services.nmap').split('\n');
const end=service.findIndex(l=>l.startsWith('1 service unrecognized'));
const screens=[
 ['01-services','Nmap service discovery - isolated Docker target',service.slice(0,end).join('\n')],
 ['02-tcp','SYN / FIN / Xmas - real packet evidence', ['syn','fin','xmas'].map(m=>`$ tshark -r evidence/verified/${m}.pcap -n\n`+read('verified/'+m+'-tshark.txt')).join('\n\n')],
 ['03-udp','UDP scan - service replies and ICMP errors', '$ nmap -sU -n -Pn --reason -p 53,69,111,137,161,65000 172.24.0.2\n'+read('verified/udp.nmap')+'\n\n$ tshark -r evidence/verified/udp.pcap -n\n'+read('verified/udp-tshark.txt')]
];
for(const [id,title,body] of screens){
 fs.writeFileSync(`${root}/${id}.html`,`<!doctype html><html lang="en"><meta charset="UTF-8"><title>${title}</title><style>*{box-sizing:border-box}body{margin:0;background:#101820;color:#e4edf5;font-family:Consolas,monospace;padding:24px}header{color:#7dd3fc;font-size:20px;border-bottom:1px solid #405363;padding-bottom:12px;margin-bottom:16px}pre{font-size:17px;line-height:1.4;margin:0;white-space:pre-wrap}footer{margin-top:16px;color:#a9bac8;font-size:14px}</style><header>${esc(title)}</header><pre>${esc(body)}</pre><footer>Real command output, rendered as terminal-style evidence. 2026-11-07. Target 172.24.0.2; scanner 172.24.0.3.</footer></html>`);
 console.log(id,body.split('\n').length,'lines');
}
