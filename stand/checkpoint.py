#!/usr/bin/env python3
"""Preserve exact per-phase log deltas; no synthetic entries."""
import json
import pathlib
import sys

files = {
    'suricata-fast.log': '/var/log/suricata/fast.log',
    'suricata-eve.json': '/var/log/suricata/eve.json',
    'fail2ban.log': '/var/log/fail2ban.log',
    'auth.log': '/var/log/auth.log',
}
root = pathlib.Path('/evidence')
root.mkdir(exist_ok=True)
statefile = root / 'offsets.json'
state = json.loads(statefile.read_text()) if statefile.exists() else {}
phase = sys.argv[1]
for name, source in files.items():
    path = pathlib.Path(source)
    raw = path.read_bytes() if path.exists() else b''
    start = state.get(name, 0)
    if start > len(raw):
        raise RuntimeError('log truncated during experiment: ' + source)
    delta = raw[start:]
    (root / (phase + '-' + name)).write_bytes(delta)
    print(f'{phase} {name}: start={start} end={len(raw)} bytes={len(delta)} lines={delta.count(bytes([10]))}')
    state[name] = len(raw)
statefile.write_text(json.dumps(state, indent=2))
