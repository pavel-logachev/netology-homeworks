import fs from 'node:fs';
import crypto from 'node:crypto';
const root='C:/Users/pavel/Documents/DeepSeekHarness/cache/netology-20261107/w-1301';
const ev=root+'/wt/evidence';const report=[];let failures=0;
function check(ok,label){report.push((ok?'PASS ':'FAIL ')+label);if(!ok)failures++;}
for(const [mode,total] of [['syn',14],['fin',10],['xmas',10],['udp',31]]){
 const b=fs.readFileSync(`${ev}/verified/${mode}.pcap`);check(b.readUInt32LE(0)===0xa1b2c3d4,`${mode} pcap magic`);
 const packets=[];let off=24;
 while(off<b.length){const len=b.readUInt32LE(off+8);off+=16;const p=b.subarray(off,off+len);off+=len;const ihl=(p[14]&15)*4;const proto=p[23];const src=[...p.subarray(26,30)].join('.');const dst=[...p.subarray(30,34)].join('.');const l4=14+ihl;packets.push({src,dst,proto,sp:p.readUInt16BE(l4),dp:p.readUInt16BE(l4+2),flags:proto===6?p[l4+13]:null,icmp:proto===1?[p[l4],p[l4+1]]:null});}
 check(off===b.length,`${mode} complete record boundaries`);check(packets.length===total,`${mode} ${total} packets`);
 const target=p=>p.src==='172.24.0.2'&&p.dst==='172.24.0.3';const scanner=p=>p.src==='172.24.0.3'&&p.dst==='172.24.0.2';
 check(packets.every(p=>target(p)||scanner(p)),`${mode} only owned target/scanner outer addresses`);
 const count=f=>packets.filter(f).length;
 if(mode==='syn'){
  for(const [label,filter,n] of [['scanner SYN',p=>scanner(p)&&p.flags===2,5],['target SYN ACK',p=>target(p)&&p.flags===18,4],['scanner RST',p=>scanner(p)&&p.flags===4,4],['closed target RST ACK',p=>target(p)&&p.flags===20&&p.sp===65000,1]])check(count(filter)===n,`${mode} ${label}=${n}`);
 }else if(mode!=='udp'){
  const flags=mode==='fin'?1:41;
  check(count(p=>scanner(p)&&p.flags===flags)===9,`${mode} 9 probes with flags ${flags}`);
  check(count(p=>target(p)&&p.sp!==65000)===0,`${mode} no reply from known-open ports`);
  check(count(p=>target(p)&&p.sp===65000&&p.flags===20)===1,`${mode} closed RST ACK=1`);
 }else{
  for(const [label,filter,n] of [['scanner UDP',p=>scanner(p)&&p.proto===17,15],['target UDP',p=>target(p)&&p.proto===17,5],['target ICMP 3/3',p=>target(p)&&p.icmp?.join('/')==='3/3',6],['scanner ICMP 3/3',p=>scanner(p)&&p.icmp?.join('/')==='3/3',5],['target UDP 111',p=>target(p)&&p.proto===17&&p.sp===111,2],['target UDP 137',p=>target(p)&&p.proto===17&&p.sp===137,3]])check(count(filter)===n,`${mode} ${label}=${n}`);
 }
 const capture=fs.readFileSync(`${ev}/verified/${mode}-capture.txt`,'utf8');check(capture.includes(`${total} packets captured`)&&capture.includes('0 packets dropped by kernel'),`${mode} tcpdump captured=${total}, kernel drops=0`);
}
const services=fs.readFileSync(ev+'/services.nmap','utf8');check((services.match(/^\d+\/tcp\s+open/gm)||[]).length===25,'25 open TCP ports');
for(const n of ['01-services.png','02-tcp.png','03-udp.png']){const b=fs.readFileSync(ev+'/'+n);check(b.readUInt32BE(16)===1560&&b.readUInt32BE(20)===1450,n+' dimensions 1560x1450');}
report.push(`Independent parser check failures=${failures}`);fs.writeFileSync(ev+'/independent-check.txt',report.join('\n')+'\n');console.log(report.join('\n'));if(failures)process.exitCode=1;
