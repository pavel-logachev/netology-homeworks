# Evidence inventory

Every file below is retained from this lab. Zero-byte phase files are intentional, not missing data. Raw logs retain native whitespace and encoding. INDEX.md is this generated inventory itself.

| File | Bytes | What it shows |
|---|---:|---|
| [01-nmap-ack-connect.html](<01-nmap-ack-connect.html>) | 3821 | HTML render source containing escaped selected actual log lines |
| [01-nmap-ack-connect.png](<01-nmap-ack-connect.png>) | 124458 | Final headless screenshot of adjacent real-output HTML, visually read_image checked |
| [02-nmap-syn-version.html](<02-nmap-syn-version.html>) | 4418 | HTML render source containing escaped selected actual log lines |
| [02-nmap-syn-version.png](<02-nmap-syn-version.png>) | 154771 | Final headless screenshot of adjacent real-output HTML, visually read_image checked |
| [03-hydra-disabled.html](<03-hydra-disabled.html>) | 3327 | HTML render source containing escaped selected actual log lines |
| [03-hydra-disabled.png](<03-hydra-disabled.png>) | 123795 | Final headless screenshot of adjacent real-output HTML, visually read_image checked |
| [04-hydra-ban.html](<04-hydra-ban.html>) | 3165 | HTML render source containing escaped selected actual log lines |
| [04-hydra-ban.png](<04-hydra-ban.png>) | 112125 | Final headless screenshot of adjacent real-output HTML, visually read_image checked |
| [artifact-checks.txt](<artifact-checks.txt>) | 1346 | Exact assertions against captured evidence with counts, isolation, ban and PNG checks |
| [attacker-inventory.txt](<attacker-inventory.txt>) | 1049 | Initial IP/route/package diagnostic; ssh -V stderr wrapped by PowerShell |
| [auth-full.log](<auth-full.log>) | 4067 | Complete sshd auth log through corrected scan pass |
| [baseline-auth.log](<baseline-auth.log>) | 93 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [baseline-checkpoint.txt](<baseline-checkpoint.txt>) | 310 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [baseline-fail2ban.log](<baseline-fail2ban.log>) | 1643 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [baseline-suricata-eve.json](<baseline-suricata-eve.json>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [baseline-suricata-fast.log](<baseline-suricata-fast.log>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [before-hydra-disabled-auth.log](<before-hydra-disabled-auth.log>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [before-hydra-disabled-checkpoint.txt](<before-hydra-disabled-checkpoint.txt>) | 400 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [before-hydra-disabled-fail2ban.log](<before-hydra-disabled-fail2ban.log>) | 448 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [before-hydra-disabled-suricata-eve.json](<before-hydra-disabled-suricata-eve.json>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [before-hydra-disabled-suricata-fast.log](<before-hydra-disabled-suricata-fast.log>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [before-hydra-enabled-auth.log](<before-hydra-enabled-auth.log>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [before-hydra-enabled-checkpoint.txt](<before-hydra-enabled-checkpoint.txt>) | 399 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [before-hydra-enabled-fail2ban.log](<before-hydra-enabled-fail2ban.log>) | 1052 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [before-hydra-enabled-suricata-eve.json](<before-hydra-enabled-suricata-eve.json>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [before-hydra-enabled-suricata-fast.log](<before-hydra-enabled-suricata-fast.log>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [build-final.txt](<build-final.txt>) | 3034 | Successful final-source image rebuild including Python helpers |
| [build-info.txt](<build-info.txt>) | 4898 | Suricata compiled features, package versions and SSH version |
| [build-ubuntu.txt](<build-ubuntu.txt>) | 92294 | Successful experiment-image build with package installs and ET Open update |
| [build.txt](<build.txt>) | 7622 | Failed initial Debian build and installation candidate diagnostic |
| [classification.config.observed](<classification.config.observed>) | 3228 | Suricata rule classification metadata copied from actual container |
| [cleanup.txt](<cleanup.txt>) | 2295 | Owned Docker teardown, already-absent image diagnostic, final zero counts |
| [commands.txt](<commands.txt>) | 3318 | Literal Docker invocations from main experiment plus corrected nmap commands |
| [containers.json](<containers.json>) | 17760 | Actual attacker/defender inspect with images, capabilities, networking and no host port bindings |
| [copy-auth-full.txt](<copy-auth-full.txt>) | 82 | Docker cp command receipt, native exit code |
| [copy-enabled-jail.txt](<copy-enabled-jail.txt>) | 100 | Docker cp command receipt, native exit code |
| [copy-fail2ban-full.txt](<copy-fail2ban-full.txt>) | 90 | Docker cp command receipt, native exit code |
| [copy-phase-evidence.txt](<copy-phase-evidence.txt>) | 63 | Docker cp command receipt, native exit code |
| [copy-suricata-config.txt](<copy-suricata-config.txt>) | 98 | Docker cp command receipt, native exit code |
| [copy-suricata-full.txt](<copy-suricata-full.txt>) | 85 | Docker cp command receipt, native exit code |
| [delivery.txt](<delivery.txt>) | 259 | Branch/base and README-equality check before commit; final commit check lives outside worktree |
| [disable-before-hydra.txt](<disable-before-hydra.txt>) | 717 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [enable-before-hydra.txt](<enable-before-hydra.txt>) | 951 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [enable-for-scans.txt](<enable-for-scans.txt>) | 886 | Initial enable-jail command and zero counters |
| [fail2ban-effective.txt](<fail2ban-effective.txt>) | 6373 | Actual fail2ban-client -d resolved configuration |
| [fail2ban-full.log](<fail2ban-full.log>) | 3763 | Complete Fail2Ban log through corrected pass, including explicit Unban |
| [fail2ban-status-banned.txt](<fail2ban-status-banned.txt>) | 294 | sshd jail status at blocked point with attacker in Banned IP list |
| [final-auth.log](<final-auth.log>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [final-checkpoint.txt](<final-checkpoint.txt>) | 327 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [final-fail2ban.log](<final-fail2ban.log>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [final-readiness-canary.txt](<final-readiness-canary.txt>) | 2101 | Final startup helper exercised against real container, fresh Engine started notice |
| [final-suricata-eve.json](<final-suricata-eve.json>) | 262024 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [final-suricata-fast.log](<final-suricata-fast.log>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [firewall-banned.txt](<firewall-banned.txt>) | 2717 | Container iptables and nft rule listing, REJECT rule and packet counters |
| [git-review.txt](<git-review.txt>) | 11861 | Staged diff stat and source-only whitespace result; raw whitespace preserved |
| [hydra-disabled-auth.log](<hydra-disabled-auth.log>) | 2074 | Task 2 no-jail phase. Suffix identifies Hydra result, log delta or offsets |
| [hydra-disabled-checkpoint.txt](<hydra-disabled-checkpoint.txt>) | 376 | Task 2 no-jail phase. Suffix identifies Hydra result, log delta or offsets |
| [hydra-disabled-fail2ban.log](<hydra-disabled-fail2ban.log>) | 0 | Task 2 no-jail phase. Suffix identifies Hydra result, log delta or offsets |
| [hydra-disabled-suricata-eve.json](<hydra-disabled-suricata-eve.json>) | 30570 | Task 2 no-jail phase. Suffix identifies Hydra result, log delta or offsets |
| [hydra-disabled-suricata-fast.log](<hydra-disabled-suricata-fast.log>) | 1501 | Task 2 no-jail phase. Suffix identifies Hydra result, log delta or offsets |
| [hydra-disabled.txt](<hydra-disabled.txt>) | 1443 | Task 2 no-jail phase. Suffix identifies Hydra result, log delta or offsets |
| [hydra-enabled-auth.log](<hydra-enabled-auth.log>) | 1188 | Task 2 enabled-jail phase including post-ban probe. Suffix identifies Hydra result, log delta or offsets |
| [hydra-enabled-checkpoint.txt](<hydra-enabled-checkpoint.txt>) | 378 | Task 2 enabled-jail phase including post-ban probe. Suffix identifies Hydra result, log delta or offsets |
| [hydra-enabled-fail2ban.log](<hydra-enabled-fail2ban.log>) | 531 | Task 2 enabled-jail phase including post-ban probe. Suffix identifies Hydra result, log delta or offsets |
| [hydra-enabled-suricata-eve.json](<hydra-enabled-suricata-eve.json>) | 1007608 | Task 2 enabled-jail phase including post-ban probe. Suffix identifies Hydra result, log delta or offsets |
| [hydra-enabled-suricata-fast.log](<hydra-enabled-suricata-fast.log>) | 7160 | Task 2 enabled-jail phase including post-ban probe. Suffix identifies Hydra result, log delta or offsets |
| [hydra-enabled.txt](<hydra-enabled.txt>) | 3405 | Task 2 enabled-jail phase including post-ban probe. Suffix identifies Hydra result, log delta or offsets |
| [hydra-post-ban.txt](<hydra-post-ban.txt>) | 1005 | Known valid pair cannot connect after ban; native exit 255 |
| [image.json](<image.json>) | 2791 | Experiment-image docker inspect |
| [initial-summary.txt](<initial-summary.txt>) | 3232 | Counts before corrected second scan pass |
| [jail.conf.observed](<jail.conf.observed>) | 25607 | Untouched package jail.conf copied as evidence of default source |
| [network.json](<network.json>) | 2288 | Internal named subnet and two owned container IPs |
| [nmap-sA-auth.log](<nmap-sA-auth.log>) | 0 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sA-checkpoint.txt](<nmap-sA-checkpoint.txt>) | 304 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sA-fail2ban.log](<nmap-sA-fail2ban.log>) | 0 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sA-jail-status.txt](<nmap-sA-jail-status.txt>) | 281 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sA-suricata-eve.json](<nmap-sA-suricata-eve.json>) | 0 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sA-suricata-fast.log](<nmap-sA-suricata-fast.log>) | 0 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sA.txt](<nmap-sA.txt>) | 497 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sS-auth.log](<nmap-sS-auth.log>) | 0 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sS-checkpoint.txt](<nmap-sS-checkpoint.txt>) | 330 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sS-fail2ban.log](<nmap-sS-fail2ban.log>) | 0 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sS-jail-status.txt](<nmap-sS-jail-status.txt>) | 281 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sS-suricata-eve.json](<nmap-sS-suricata-eve.json>) | 627729 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sS-suricata-fast.log](<nmap-sS-suricata-fast.log>) | 178008 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sS.txt](<nmap-sS.txt>) | 434 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sT-auth.log](<nmap-sT-auth.log>) | 0 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sT-checkpoint.txt](<nmap-sT-checkpoint.txt>) | 304 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sT-fail2ban.log](<nmap-sT-fail2ban.log>) | 0 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sT-jail-status.txt](<nmap-sT-jail-status.txt>) | 281 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sT-suricata-eve.json](<nmap-sT-suricata-eve.json>) | 0 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sT-suricata-fast.log](<nmap-sT-suricata-fast.log>) | 0 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sT.txt](<nmap-sT.txt>) | 440 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sV-auth.log](<nmap-sV-auth.log>) | 356 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sV-checkpoint.txt](<nmap-sV-checkpoint.txt>) | 344 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sV-fail2ban.log](<nmap-sV-fail2ban.log>) | 0 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sV-jail-status.txt](<nmap-sV-jail-status.txt>) | 281 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sV-suricata-eve.json](<nmap-sV-suricata-eve.json>) | 622724 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sV-suricata-fast.log](<nmap-sV-suricata-fast.log>) | 178470 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [nmap-sV.txt](<nmap-sV.txt>) | 662 | Initial scan phase retained for audit; sA/sT began before engine readiness and are not authoritative detection evidence |
| [no-external-route.txt](<no-external-route.txt>) | 394 | Kernel route lookup fails; no external attack traffic sent |
| [offsets.json](<offsets.json>) | 110 | Final byte offsets used by checkpoint helper |
| [package-versions.txt](<package-versions.txt>) | 290 | Exact package versions and attacker connected route |
| [post-scans-status.txt](<post-scans-status.txt>) | 832 | Cumulative jail status and firewall after explicit unban and scans |
| [rules-metadata.txt](<rules-metadata.txt>) | 5750 | Merged/local rule hashes and selected active ET signatures |
| [run-transcript.txt](<run-transcript.txt>) | 22667 | Complete initial orchestration transcript including successful disabled Hydra and blocked enabled Hydra |
| [runtime-inventory.txt](<runtime-inventory.txt>) | 1342 | Real running processes, enabled jail, base firewall and rule hash/count |
| [selected-et-rules.txt](<selected-et-rules.txt>) | 2484 | Active exact selected ET signature bodies selected with Python after shell quote error |
| [sshd-effective.txt](<sshd-effective.txt>) | 4452 | sshd -T effective configuration |
| [startup.txt](<startup.txt>) | 942 | Compose startup and health results |
| [stop-suricata.txt](<stop-suricata.txt>) | 99 | Controlled first IDS stop command |
| [summary.txt](<summary.txt>) | 6291 | Recomputed exact per-window EVE alert signatures and Fail2Ban counts |
| [suricata-configuration.txt](<suricata-configuration.txt>) | 259 | Printed active network variables, af-packet settings and rule files |
| [suricata-full/eve.json](<suricata-full/eve.json>) | 7354781 | Unfiltered combined real Suricata log through corrected scan pass |
| [suricata-full/fast.log](<suricata-full/fast.log>) | 1062906 | Unfiltered combined real Suricata log through corrected scan pass |
| [suricata-full/stats.log](<suricata-full/stats.log>) | 55225 | Unfiltered combined real Suricata log through corrected scan pass |
| [suricata-full/suricata.log](<suricata-full/suricata.log>) | 6068 | Unfiltered combined real Suricata log through corrected scan pass |
| [suricata-start.txt](<suricata-start.txt>) | 219 | Initial daemon start command exit 0, insufficient alone to prove readiness |
| [suricata-startup.log](<suricata-startup.log>) | 3459 | Diagnostic copy showing late Engine started in initial pass |
| [suricata-test.txt](<suricata-test.txt>) | 150 | Actual suricata -T configuration successfully loaded |
| [suricata-uptime.txt](<suricata-uptime.txt>) | 851 | Diagnostic unix-command uptime query |
| [verified-nmap-sA-auth.log](<verified-nmap-sA-auth.log>) | 0 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sA-checkpoint.txt](<verified-nmap-sA-checkpoint.txt>) | 300 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sA-fail2ban.log](<verified-nmap-sA-fail2ban.log>) | 0 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sA-jail-status.txt](<verified-nmap-sA-jail-status.txt>) | 201 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sA-suricata-eve.json](<verified-nmap-sA-suricata-eve.json>) | 635337 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sA-suricata-fast.log](<verified-nmap-sA-suricata-fast.log>) | 163316 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sA.txt](<verified-nmap-sA.txt>) | 489 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sS-auth.log](<verified-nmap-sS-auth.log>) | 0 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sS-checkpoint.txt](<verified-nmap-sS-checkpoint.txt>) | 300 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sS-fail2ban.log](<verified-nmap-sS-fail2ban.log>) | 0 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sS-jail-status.txt](<verified-nmap-sS-jail-status.txt>) | 201 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sS-suricata-eve.json](<verified-nmap-sS-suricata-eve.json>) | 626961 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sS-suricata-fast.log](<verified-nmap-sS-suricata-fast.log>) | 177812 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sS.txt](<verified-nmap-sS.txt>) | 425 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sT-auth.log](<verified-nmap-sT-auth.log>) | 0 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sT-checkpoint.txt](<verified-nmap-sT-checkpoint.txt>) | 300 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sT-fail2ban.log](<verified-nmap-sT-fail2ban.log>) | 0 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sT-jail-status.txt](<verified-nmap-sT-jail-status.txt>) | 201 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sT-suricata-eve.json](<verified-nmap-sT-suricata-eve.json>) | 629326 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sT-suricata-fast.log](<verified-nmap-sT-suricata-fast.log>) | 178169 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sT.txt](<verified-nmap-sT.txt>) | 431 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sV-auth.log](<verified-nmap-sV-auth.log>) | 356 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sV-checkpoint.txt](<verified-nmap-sV-checkpoint.txt>) | 303 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sV-fail2ban.log](<verified-nmap-sV-fail2ban.log>) | 0 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sV-jail-status.txt](<verified-nmap-sV-jail-status.txt>) | 201 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sV-suricata-eve.json](<verified-nmap-sV-suricata-eve.json>) | 628884 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sV-suricata-fast.log](<verified-nmap-sV-suricata-fast.log>) | 178470 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-nmap-sV.txt](<verified-nmap-sV.txt>) | 651 | Authoritative Task 1 corrected-readiness scan phase. Suffix identifies nmap output, exact log delta, offset counts or jail status |
| [verified-scans-baseline-auth.log](<verified-scans-baseline-auth.log>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [verified-scans-baseline-fail2ban.log](<verified-scans-baseline-fail2ban.log>) | 89 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [verified-scans-baseline-suricata-eve.json](<verified-scans-baseline-suricata-eve.json>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [verified-scans-baseline-suricata-fast.log](<verified-scans-baseline-suricata-fast.log>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [verified-scans-final-auth.log](<verified-scans-final-auth.log>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [verified-scans-final-checkpoint.txt](<verified-scans-final-checkpoint.txt>) | 318 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [verified-scans-final-fail2ban.log](<verified-scans-final-fail2ban.log>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [verified-scans-final-suricata-eve.json](<verified-scans-final-suricata-eve.json>) | 2283618 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [verified-scans-final-suricata-fast.log](<verified-scans-final-suricata-fast.log>) | 0 | Boundary checkpoint or exact log delta outside attack windows; zero-byte files intentionally represent no new entries |
| [verified-scans-readiness.txt](<verified-scans-readiness.txt>) | 2630 | Fresh Engine started, explicit attacker unban, cumulative baseline status and READY_FOR_SCANS |
| [verified-scans-transcript.txt](<verified-scans-transcript.txt>) | 2947 | Complete corrected four-scan output and byte checkpoints |
| [versions.txt](<versions.txt>) | 1969 | Observed binary versions, kernel, defender addresses, listeners and iptables backend |
