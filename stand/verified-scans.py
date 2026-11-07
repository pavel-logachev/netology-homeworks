#!/usr/bin/env python3
"""Second scan pass with observed IDS readiness, isolated per-mode deltas."""
import pathlib
import subprocess
import time
log = pathlib.Path('/var/log/suricata/suricata.log')
offset = log.stat().st_size
subprocess.run(['suricata', '-D', '-c', '/etc/suricata/suricata.yaml', '--af-packet=eth0', '-k', 'none', '--pidfile', '/var/run/suricata.pid'], check=True)
end = time.monotonic() + 60
while time.monotonic() < end:
    data = log.read_bytes()[offset:].decode(errors='replace')
    if 'Engine started.' in data:
        print(data, flush=True)
        break
    time.sleep(0.5)
else:
    raise RuntimeError('No Engine started notice within 60 seconds')
subprocess.run(['fail2ban-client', 'set', 'sshd', 'unbanip', '172.30.133.20'], check=True)
subprocess.run(['fail2ban-client', 'status', 'sshd'], check=True)
subprocess.run(['python3', '/lab/checkpoint.py', 'verified-scans-baseline'], check=True)
print('READY_FOR_SCANS', flush=True)
