#!/bin/sh
# Local-only ttyd helper. Credentials are inherited, never echoed.
export PS1='netology@nt-1209:~$ '
export LANG=C.UTF-8
export TERM=xterm-256color
exec bash --noprofile --norc -i
