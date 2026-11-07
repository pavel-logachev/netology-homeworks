#!/usr/bin/env python3
import pathlib
import yaml
p = pathlib.Path('/etc/suricata/suricata.yaml')
c = yaml.safe_load(p.read_text())
c['vars']['address-groups']['HOME_NET'] = '[172.30.133.10]'
c['vars']['address-groups']['EXTERNAL_NET'] = '!$HOME_NET'
c['rule-files'] = ['suricata.rules', 'local.rules']
c['af-packet'] = [{'interface': 'eth0', 'threads': 1, 'cluster-id': 1303, 'cluster-type': 'cluster_flow', 'defrag': True, 'use-mmap': True, 'tpacket-v3': True}]
for output in c['outputs']:
    if 'eve-log' in output:
        output['eve-log']['enabled'] = True
        output['eve-log']['types'] = ['alert', 'ssh', 'flow', 'stats']
    if 'fast' in output:
        output['fast']['enabled'] = True
p.write_text('%YAML 1.1\n---\n' + yaml.safe_dump(c, sort_keys=False))
print('HOME_NET:', c['vars']['address-groups']['HOME_NET'])
print('EXTERNAL_NET:', c['vars']['address-groups']['EXTERNAL_NET'])
print('rule-files:', c['rule-files'])
print('af-packet:', c['af-packet'])
