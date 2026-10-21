#!/usr/bin/env bash
set -euo pipefail
# Official static x86_64 release, pinned and checksum-checked; no browser/GUI emulation.
wget -T 30 -O /tmp/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64
printf '8a217c968aba172e0dbf3f34447218dc015bc4d5e59bf51db2f2cd12b7be4f55  /tmp/ttyd\n' | sha256sum -c -
chmod +x /tmp/ttyd
export TERM=xterm-256color
exec /tmp/ttyd -W -p 7681 -t fontSize=18 -t 'theme={"background":"#10151c","foreground":"#edf2f7"}' bash --noprofile --norc
