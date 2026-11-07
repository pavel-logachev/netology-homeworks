import pathlib
import re
rules = pathlib.Path('/var/lib/suricata/rules/suricata.rules')
text = rules.read_text()
selected = {2001219, 2006546, 2010935, 2010936, 2010937, 2010939, 2002910}
for line in text.splitlines():
    sid = re.search(r'\bsid:([0-9]+);', line)
    if sid and int(sid[1]) in selected:
        print(line)
