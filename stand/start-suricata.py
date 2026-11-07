#!/usr/bin/env python3
"""Start IDS and require its own engine-start notice, not just daemon exit 0."""
import pathlib
import subprocess
import time
log = pathlib.Path('/var/log/suricata/suricata.log')
offset = log.stat().st_size if log.exists() else 0
subprocess.run(['suricata', '-D', '-c', '/etc/suricata/suricata.yaml', '--af-packet=eth0', '-k', 'none', '--pidfile', '/var/run/suricata.pid'], check=True)
deadline = time.monotonic() + 60
while time.monotonic() < deadline:
    data = log.read_bytes()[offset:].decode(errors='replace') if log.exists() else ''
    if 'Engine started.' in data:
        print(data, flush=True)
        break
    time.sleep(0.5)
else:
    raise RuntimeError('No Engine started notice within 60 seconds')
