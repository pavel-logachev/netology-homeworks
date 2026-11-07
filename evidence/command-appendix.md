# Host, source and rendering command appendix

Run date 2026-11-07. Root below is the actually used cache root, not a placeholder for another stand.

```powershell
$root='C:\Users\pavel\Documents\DeepSeekHarness\cache\netology-20261107\w-1301'
$repo='C:\Users\pavel\Documents\Projects\devops-practice\netology-homeworks'
$e="$root\wt\evidence"
$pw='C:\Users\pavel\Documents\DeepSeekHarness\tools\playwright\playwright-dsh.cmd'
```

## Initial host/Git inspection, before first write

```powershell
Get-Date -Format o
git -C $repo status --short
git -C $repo branch --list 13-01-vulnerabilities
docker version
docker ps -a --filter name=nt1301-
docker network ls --filter name=nt1301-
```

Repository status empty; requested branch absent; prefix Docker listings empty. These initial calls preceded the file logger. A subsequent preflight rerun was saved to preflight.txt.

```powershell
New-Item -ItemType Directory -Path $root -Force | Out-Null
git -C $repo worktree add "$root\wt" -b 13-01-vulnerabilities origin/main
New-Item -ItemType Directory -Path "$root\wt\evidence" | Out-Null
git -C "$root\wt" rev-parse HEAD
git -C "$root\wt" ls-tree -r --name-only 12-08-backup
git -C "$root\wt" show 12-08-backup:README.md
docker pull tleemcjr/metasploitable2:latest
docker pull nicolaka/netshoot:latest
```

Pull job pwsh-78b6f47c92524df8 completed0. Digests recorded in pulls.txt and independently in images.jsonl.

```powershell
& { Get-Date -Format o; git -C "$e\.." rev-parse HEAD; git -C "$e\.." branch --show-current; docker version; docker ps -a --filter name=nt1301-; docker network ls --filter name=nt1301- } 2>&1 | Out-File -LiteralPath "$e\preflight.txt" -Encoding utf8
Get-Command node | Select-Object Source
Test-Path $pw
```

## Stand execution

Every Docker call in the scripts is expanded with actual arguments in commands.txt. These are the exact host entry points, in order. Setup/capture scripts are copied into evidence; do not rerun them against another person's stand.

```powershell
& "$root\setup.ps1" # execution policy error, no script actions
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$root\setup.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$root\resume-setup.ps1"
docker network inspect nt1301-lab | Out-File "$e\network.json" -Encoding utf8
docker inspect nt1301-target nt1301-scanner | Out-File "$e\containers.json" -Encoding utf8
docker exec nt1301-target sh -c 'testparm -sv 2>/dev/null | grep -i username; /usr/bin/distccd --version; /usr/bin/unrealircd -v' 2>&1 | Out-File "$e\version-details.txt" -Encoding utf8
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$root\scan.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$root\capture.ps1"
docker exec nt1301-target sh -c 'dpkg-query -W vsftpd samba samba-common proftpd openssh-server apache2 mysql-server-5.0 postgresql-8.3 tomcat5.5; testparm -s 2>/dev/null' 2>&1 | Out-File "$e\packages-and-samba.txt" -Encoding utf8
docker exec nt1301-capture tcpdump --help
docker exec nt1301-capture tshark -r /evidence/udp.pcap -n -Y 'ip.src#1==172.24.0.2 and icmp.type==3' -T fields -e frame.number
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$root\capture-verified.ps1"
```

The diagnostic tshark command against the first pcap returned target outer-header frames2,4,6,8,18,21 (6, rather than the naive nested-IP count11). Capture-verified reran all modes with immediate capture; final figures in verified/traffic-counts.txt supersede all first-pass figures.

```powershell
docker exec nt1301-scanner nmap -sV --version-all --script smb-os-discovery,irc-info -p 21,139,445,6667 -n -Pn --host-timeout 2m -oA /evidence/versions-confirmed 172.24.0.2
```

The actual enumeration output was piped to versions-confirmed-console.txt with Out-File -Encoding utf8 and the command appended to commands.txt. All scan destinations are the owned target172.24.0.2, no internet scan.

## Source fetching

DSH web_fetch exact URLs, all HTTP200 returned and read in session

- https://www.exploit-db.com/exploits/17491
- https://www.exploit-db.com/exploits/49757 (duplicate vsftpd record, not counted separately)
- https://www.exploit-db.com/exploits/10099 (unrelated HP record, discarded)
- https://www.exploit-db.com/exploits/16320
- https://www.exploit-db.com/exploits/16922
- https://hub.docker.com/r/tleemcjr/metasploitable2/ (response only title; not used as service evidence)

DSH web_search queries used for discovery only

- tleemcjr metasploitable2 Docker services.sh start
- site:exploit-db.com Samba 3.0.20 username map script 16320
- site:exploit-db.com UnrealIRCd 3.2.8.1 16922
- site:exploit-db.com distcc 2.18 3632 command execution 9915 (optional lead, not cited as one of three findings)

`node "$root\sources.mjs"` attempted to save five EDB HTML documents with a30-second per-request AbortSignal timeout. All403 Sucuri, no retries. Failed raw HTML and source-<id>.txt diagnostics live outside the worktree. Successful web_fetch quotes are saved in source-confirmed.txt; no exploit source was executed.

## Screenshot generation

```powershell
node "$root\render.mjs"
& $pw -s=w1301 open file:///C:/Users/pavel/Documents/DeepSeekHarness/cache/netology-20261107/w-1301/01-services.html
# Error: Access to "file:" protocol is blocked. Browser was opened headlessly.
node "$root\render-server.mjs" # managed background job, loopback8131
& $pw -s=w1301 goto http://127.0.0.1:8131/01-services.html
& $pw -s=w1301 resize 1560 1450
& $pw -s=w1301 screenshot --filename="$e\01-services.png"
& $pw -s=w1301 goto http://127.0.0.1:8131/02-tcp.html
& $pw -s=w1301 screenshot --filename="$e\02-tcp.png"
& $pw -s=w1301 goto http://127.0.0.1:8131/03-udp.html
& $pw -s=w1301 screenshot --filename="$e\03-udp.png"
node "$root\finalize-files.mjs" # moves owned superseded attempts to diagnostics-first-attempt, copies scripts
& $pw -s=w1301 console # final page 0 errors,0 warnings
& $pw -s=w1301 close
```

All three PNGs opened with DSH read_image and visually confirmed legible. Initial page navigation reported1 console error; no conclusion depends on the console. The headless browser was closed and render server job pwsh-e1727e8c6eda427e canceled after use.

## Independent checks and cleanup

```powershell
node "$root\verify.mjs"
Copy-Item -LiteralPath "$root\verify.mjs" -Destination "$e\verify.mjs"
git -C "$root\wt" diff origin/main -- README.md
git -C "$root\wt" status --short
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$root\cleanup.ps1"
Copy-Item -LiteralPath "$root\cleanup.ps1" -Destination "$e\cleanup.ps1"
```

Byte-level parser failures0, README diff empty. Cleanup exact Docker commands/output are in cleanup.txt and commands.txt. Final inventory/hash/staging/commit checks are recorded in delivery.txt outside the worktree and final acceptance receipt in FACTS.md.

Text files were created/edited with DSH write/edit; directory discovery used glob, text inspection read, rendered PNG inspection read_image, repository instruction lookup glob found no project AGENTS.md. No memory writes or agents were used.

## Final delivery commands

```powershell
node "$root\inventory.mjs"
git -C "$root\wt" add -- evidence
git -C "$root\wt" diff --cached --stat
git -C "$root\wt" diff --cached --numstat
git -C "$root\wt" diff --cached --check
git -C "$root\wt" diff --cached --name-only
git -C "$root\wt" diff origin/main -- README.md
```

The whitespace check reported trailing whitespace in raw netstat/ps/Nmap outputs. Those bytes intentionally remain unchanged; this is raw evidence, not authored source formatting. Git warned about automatic LF-to-CRLF conversion. To preserve original bytes and the SHA256 manifest, the owned evidence/.gitattributes sets `* -text` (only within evidence), then the evidence was restaged with `git add --renormalize -- evidence`. No repository-wide config was changed. Final staged-blob identity comparison covers every file, including the4 binary pcaps and3 PNGs. Secret-pattern preflight returned0 high-risk private-key/token matches; known disposable service banner text is not a user credential.

```powershell
node "$root\inventory.mjs"
git -C "$root\wt" add -- evidence/.gitattributes
git -C "$root\wt" add --renormalize -- evidence
# For each owned evidence file compare git hash-object --no-filters <path> with git rev-parse :<path>.
git -C "$root\wt" diff --cached --name-only
git -C "$root\wt" diff --cached -- evidence/.gitattributes evidence/analyze.sh evidence/capture-verified.ps1 evidence/source-confirmed.txt
git -C "$root\wt" commit -m 'lab: collect verified Metasploitable scan evidence for 13-01'
git -C "$root\wt" log --oneline -1
git -C "$root\wt" branch --show-current
git -C "$root\wt" status
git -C "$root\wt" diff origin/main -- README.md
git -C "$root\wt" rev-parse HEAD^
git -C "$root\wt" diff-tree --no-commit-id --name-only -r HEAD
docker ps -a --filter name=nt1301-
docker network ls --filter name=nt1301-
```

Final checks are saved outside the worktree to delivery.txt to leave the one evidence commit clean. Those commands do not write more evidence after the SHA256 manifest.
