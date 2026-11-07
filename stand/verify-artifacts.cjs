const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const e = path.join(root, 'evidence');
const read = n => fs.readFileSync(path.join(e,n), 'utf8').replace(/^\uFEFF/, '');
const events = n => read(n).trim().split('\n').filter(Boolean).map(x => JSON.parse(x));
const alerts = n => events(n).filter(x => x.event_type === 'alert');
const net = JSON.parse(read('network.json'))[0];
assert.equal(net.Name, 'nt1303-isolated'); assert.equal(net.Internal, true);
assert.deepEqual(Object.values(net.Containers).map(x => x.Name).sort(), ['nt1303-attacker','nt1303-defender']);
for (const c of JSON.parse(read('containers.json'))) {
  assert.equal(Object.keys(c.HostConfig.PortBindings || {}).length, 0);
  assert.equal(c.HostConfig.Privileged, false);
  assert(c.Name.startsWith('/nt1303-'));
}
console.log('PASS ownership/isolation: internal network, exactly two owned containers, no published ports, no privileged mode');
for (const [mode, count] of Object.entries({sA:1002,sT:1006,sS:1004,sV:1008})) {
  const p = 'verified-nmap-' + mode;
  assert(read(p + '.txt').includes('[exit code: 0]'));
  const a = alerts(p + '-suricata-eve.json');
  assert.equal(a.length, count);
  assert.equal(fs.statSync(path.join(e,p + '-fail2ban.log')).size, 0);
  assert(read(p + '-jail-status.txt').includes('Total failed:\t4'));
  assert(read(p + '-jail-status.txt').includes('Currently banned:\t0'));
  const et = a.filter(x => !x.alert.signature.startsWith('LAB LOCAL'));
  console.log(`PASS ${mode}: ${a.length} alerts (${et.length} non-local), Fail2Ban delta 0 bytes, cumulative failures 4, currently banned 0`);
}
assert(read('verified-nmap-sA.txt').includes('1000 unfiltered tcp ports'));
for (const mode of ['sT','sS','sV']) assert(read('verified-nmap-' + mode + '.txt').includes('22/tcp open'));
assert(read('verified-nmap-sV.txt').includes('OpenSSH 9.6p1'));
assert(read('hydra-disabled.txt').includes('1 valid password found'));
assert(read('hydra-disabled-auth.log').includes('Accepted password for labuser'));
assert.equal((read('hydra-disabled-auth.log').match(/Failed password/g)||[]).length,5);
assert.equal(fs.statSync(path.join(e,'hydra-disabled-fail2ban.log')).size,0);
const banlog = read('hydra-enabled-fail2ban.log');
assert.equal((banlog.match(/\[sshd\] Found /g)||[]).length,4);
assert.equal((banlog.match(/\[sshd\] Ban 172\.30\.133\.20/g)||[]).length,1);
assert(read('fail2ban-status-banned.txt').includes('Currently banned:\t1'));
assert(read('firewall-banned.txt').includes('-A f2b-sshd -s 172.30.133.20/32 -j REJECT'));
assert(read('hydra-enabled.txt').includes('0 valid password found'));
assert(read('hydra-post-ban.txt').includes('Connection refused'));
assert(alerts('hydra-disabled-suricata-eve.json').some(x => x.alert.signature_id === 2001219));
assert(alerts('hydra-enabled-suricata-eve.json').some(x => x.alert.signature_id === 9901303));
console.log('PASS hydra disabled: 5 failed passwords then 1 accepted password, F2B delta 0, ET SID 2001219');
console.log('PASS hydra enabled: Found=4 Ban=1, banned status=1, REJECT rule, zero valid passwords, post-ban connection refused, local SID 9901303');
for (const n of ['01-nmap-ack-connect','02-nmap-syn-version','03-hydra-disabled','04-hydra-ban']) {
 const data=fs.readFileSync(path.join(e,n+'.png'));
 assert.equal(data.subarray(1,4).toString(),'PNG');
 assert(data.length>100000);
 assert.equal(data.readUInt32BE(16),1600); assert.equal(data.readUInt32BE(20),1100);
 assert(read(n+'.html').includes('real Docker output'));
 console.log(`PASS ${n}.png: 1600x1100, ${data.length} bytes; visual legibility independently checked using read_image`);
}
assert(read('verified-scans-readiness.txt').includes('Engine started.'));
assert(read('final-readiness-canary.txt').includes('Engine started.'));
console.log('PASS original corrected scan readiness and final startup helper live canary');
const files=fs.readdirSync(e,{recursive:true}).filter(n => fs.statSync(path.join(e,n)).isFile());
console.log(`Evidence files observed: ${files.length}`);
console.log('PASS exact artifact checks complete');
