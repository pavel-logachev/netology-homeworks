# Agent-facing reproduction notes

This is an intentionally insecure, disposable homework lab. Do not publish port 22, connect it to a production network, or reuse the synthetic password. Both services run root because the lab exercises sshd, AF_PACKET, Fail2Ban and container-local netfilter. Capabilities are NET_ADMIN and NET_RAW, never privileged or host networking.

From the worktree root in PowerShell:

```powershell
docker compose --progress plain -f stand\compose.yaml build
docker compose -f stand\compose.yaml up -d --wait --wait-timeout 60
powershell -NoProfile -ExecutionPolicy Bypass -File stand\run-lab.ps1
python stand\summarize-evidence.py
node stand\render-evidence.cjs
```

The build downloads ET Open before the isolated internal runtime network exists. Package versions and the moving ET snapshot can change on a future build. The recorded run's exact versions and rule SHA-256 are in evidence. The final run-lab.ps1 uses an observed Engine started notice rather than the insufficient five-second delay used initially. The initial run and verified-scans rerun remain in evidence for audit; do not rerun over them unless preserving them separately.

To reproduce the readiness-corrected second scan pass after the main experiment:

```powershell
docker exec nt1303-defender python3 /lab/verified-scans.py
# Proceed only after READY_FOR_SCANS.
powershell -NoProfile -ExecutionPolicy Bypass -File stand\run-verified-scans.ps1
```

`jail.local` starts disabled. The script enables it for scans, disables it for the first Hydra, then enables it with `logpath = /var/log/auth.log tail`. The tail option avoids retroactive bans from the disabled phase. It does not delete logs. The second scan pass explicitly unbans the attacker after preserving ban evidence. Cumulative Fail2Ban counters therefore retain the earlier 4 matches and 1 ban; per-phase log deltas establish no new matches during scans.

Screenshots are rendered excerpts of actual adjacent raw logs, not terminal emulation or evidence of an interactive terminal. Use the installed DSH Playwright wrapper with session w1303. In this session file:// was blocked, so the same HTML was served by `python -m http.server 18133 --bind 127.0.0.1 --directory <absolute evidence path>` and opened with `goto http://127.0.0.1:18133/<name>.html`. Viewport 1600x1100. The four PNGs were opened with read_image and were legible. Stop the loopback server after capture.

Cleanup only the owned objects:

```powershell
docker compose -f stand\compose.yaml down
docker image rm nt1303-lab:noble
docker ps -a --filter name=nt1303-
docker network ls --filter name=nt1303-
```

No named volumes or host port mappings are defined. The final image was rebuild-checked with the added source scripts; actual experiments used the earlier image ID recorded in evidence/image.json. README is intentionally untouched.
