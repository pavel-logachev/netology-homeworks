#!/usr/bin/env python3
"""Exact counts and timestamps from raw evidence. Run on host with Python or in lab."""
import collections
import json
import pathlib
root = pathlib.Path(__file__).resolve().parents[1] / 'evidence'
for p in sorted(root.glob('*-suricata-eve.json')):
    events = [json.loads(line) for line in p.read_text(encoding='utf-8-sig').splitlines() if line.strip()]
    alerts = [e for e in events if e.get('event_type') == 'alert']
    print(p.name, 'events=', len(events), 'alerts=', len(alerts))
    for (sid, sig), n in collections.Counter((e['alert']['signature_id'], e['alert']['signature']) for e in alerts).items():
        subset = [e for e in alerts if e['alert']['signature_id'] == sid]
        print(' ', sid, n, sig, subset[0]['timestamp'], '..', subset[-1]['timestamp'])
for p in sorted(root.glob('*-fail2ban.log')):
    text = p.read_text(encoding='utf-8-sig')
    print(p.name, 'bytes=', p.stat().st_size, 'Found=', text.count('[sshd] Found '), 'Ban=', text.count('[sshd] Ban '))
