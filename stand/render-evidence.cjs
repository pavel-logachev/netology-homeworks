const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../evidence');
const read = name => fs.readFileSync(path.join(root, name), 'utf8').replace(/^\uFEFF/, '');
const esc = s => s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
const lines = s => s.trimEnd().split(/\r?\n/);
const block = (name, text) => `<section><h2>${esc(name)}</h2><pre>${esc(text)}</pre></section>`;
function scan(mode) {
  const p = 'verified-nmap-' + mode;
  const alerts = lines(read(p + '-suricata-fast.log'));
  const local = alerts.find(l => l.includes('LAB LOCAL'));
  const et = alerts.filter(l => l.includes('ET SCAN'));
  return block(p + '.txt', read(p + '.txt')) + block(p + '-suricata-fast.log (selected raw lines)', [local, ...et.slice(0, 2)].filter(Boolean).join('\n')) + block(p + '-checkpoint.txt (exact log sizes)', lines(read(p + '-checkpoint.txt')).filter(l => /fast.log|fail2ban.log|auth.log/.test(l)).join('\n')) + block(p + '-jail-status.txt (selected raw lines)', lines(read(p + '-jail-status.txt')).filter(l => /Total failed|Currently banned|Total banned/.test(l)).join('\n'));
}
const html = (title, body) => `<!doctype html><meta charset="utf-8"><title>${esc(title)}</title><style>html{background:#101923;color:#e9f0f7}body{margin:28px;font:16px/1.4 Consolas,monospace}h1{font:600 24px Segoe UI,sans-serif;color:#8ed7f7;margin:0 0 8px}p{color:#b2c6d7;margin:8px 0 18px}section{background:#182634;border:1px solid #31485b;padding:10px 14px;margin:10px 0;border-radius:6px}h2{font:600 16px Segoe UI,sans-serif;color:#9fe2c1;margin:0 0 5px}pre{margin:0;white-space:pre-wrap;overflow-wrap:anywhere;font:14px/1.35 Consolas,monospace}.cols{display:grid;grid-template-columns:1fr 1fr;gap:18px}</style><h1>${esc(title)}</h1><p>Netology 13-03 | real Docker output | UTC 2026-11-07 | defender 172.30.133.10, attacker 172.30.133.20<br>LAB LOCAL signatures are lab instrumentation, not ET Open. Excerpts retain raw text; full logs are adjacent.</p>${body}`;
const pages = {
  '01-nmap-ack-connect': ['Task 1 | ACK and TCP connect scans', `<div class="cols"><div>${scan('sA')}</div><div>${scan('sT')}</div></div>`],
  '02-nmap-syn-version': ['Task 1 | SYN and version detection scans', `<div class="cols"><div>${scan('sS')}</div><div>${scan('sV')}</div></div>`],
  '03-hydra-disabled': ['Task 2 | SSH jail disabled', block('disable-before-hydra.txt (selected raw lines)', lines(read('disable-before-hydra.txt')).filter(l => /OK|Number of jail|Jail list/.test(l)).join('\n')) + block('hydra-disabled.txt (selected raw lines)', lines(read('hydra-disabled.txt')).filter(l => /^docker |\[DATA\]|\[ATTEMPT\]|\[22\]|valid pair found|valid password found|exit code/.test(l)).join('\n')) + block('hydra-disabled-auth.log (selected raw lines)', lines(read('hydra-disabled-auth.log')).filter(l => /Failed password|Accepted password/.test(l)).join('\n')) + block('hydra-disabled-suricata-fast.log (ET alert)', lines(read('hydra-disabled-suricata-fast.log')).filter(l => /ET SCAN/.test(l)).join('\n')) + block('hydra-disabled-checkpoint.txt (Fail2Ban delta)', lines(read('hydra-disabled-checkpoint.txt')).filter(l => /fail2ban.log/.test(l)).join('\n'))],
  '04-hydra-ban': ['Task 2 | SSH jail enabled, attacker banned', block('hydra-enabled-fail2ban.log', read('hydra-enabled-fail2ban.log')) + `<div class="cols"><div>${block('fail2ban-status-banned.txt', read('fail2ban-status-banned.txt'))}${block('firewall-banned.txt (iptables -S)', lines(read('firewall-banned.txt')).slice(1,8).join('\n'))}</div><div>${block('hydra-enabled.txt (selected raw lines)', lines(read('hydra-enabled.txt')).filter(l => /0 valid password|connection errors|target was disabled|exit code/.test(l)).join('\n'))}${block('hydra-post-ban.txt (selected raw lines)', lines(read('hydra-post-ban.txt')).filter(l => /^docker |\[DATA\]|Connection refused|exit code/.test(l)).join('\n'))}</div></div>` + block('hydra-enabled-suricata-fast.log (LAB LOCAL alert)', lines(read('hydra-enabled-suricata-fast.log')).filter(l => /9901303/.test(l)).join('\n'))],
};
for (const [name, [title, body]] of Object.entries(pages)) {
  fs.writeFileSync(path.join(root, name + '.html'), html(title, body));
  console.log(name + '.html');
}
