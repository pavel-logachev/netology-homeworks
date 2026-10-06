"""Create only this lab's VMs from an Ubuntu cloud VMDK (requires pycdlib).
Usage: python create-vms.py --image <vmdk> --state <private-directory> --public-key <pub>
Private disks, generated cloud-init and keys belong outside Git.
"""
import argparse
import io
from pathlib import Path
import subprocess
import pycdlib

p = argparse.ArgumentParser()
p.add_argument('--image', type=Path, required=True)
p.add_argument('--state', type=Path, required=True)
p.add_argument('--public-key', type=Path, required=True)
p.add_argument('--vbox', default=r'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe')
a = p.parse_args()
a.state.mkdir(parents=True, exist_ok=True)
key = a.public_key.read_text().strip()

def vbox(*args):
    subprocess.run([a.vbox, *map(str, args)], check=True)

for i in (1, 2):
    name, hostname = f'netology-rmq0{i}', f'rmq0{i}'
    disk, seed = a.state / f'{name}.vdi', a.state / f'{name}-seed.iso'
    if disk.exists() or seed.exists():
        raise SystemExit(f'Refusing existing state: {disk} / {seed}')
    user = f'''#cloud-config
hostname: {hostname}
manage_etc_hosts: false
users:
  - name: ubuntu
    groups: [sudo]
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true
    ssh_authorized_keys:
      - {key}
ssh_pwauth: false
disable_root: true
write_files:
  - path: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    content: 'network: {{config: disabled}}'
'''
    network = f'''version: 2
ethernets:
  enp0s3:
    dhcp4: true
  enp0s8:
    dhcp4: false
    addresses: [192.168.56.{110+i}/24]
'''
    iso = pycdlib.PyCdlib()
    iso.new(interchange_level=3, joliet=3, vol_ident='cidata')
    for filename, text in [('user-data', user), ('meta-data', f'instance-id: {name}\nlocal-hostname: {hostname}\n'), ('network-config', network)]:
        data = text.encode()
        iso.add_fp(io.BytesIO(data), len(data), iso_path='/' + filename.upper().replace('-', '_') + ';1', joliet_path='/' + filename)
    iso.write(str(seed)); iso.close()
    vbox('clonemedium', 'disk', a.image, disk, '--format', 'VDI')
    vbox('modifymedium', 'disk', disk, '--resize', '16384')
    vbox('createvm', '--name', name, '--ostype', 'Ubuntu_64', '--basefolder', a.state, '--register')
    vbox('modifyvm', name, '--memory', '3072', '--cpus', '2', '--firmware', 'efi', '--graphicscontroller', 'vmsvga', '--nic1', 'nat', '--nic2', 'hostonly', '--hostonlyadapter2', 'VirtualBox Host-Only Ethernet Adapter', '--macaddress1', f'080027AA110{i}', '--macaddress2', f'080027AA120{i}')
    vbox('storagectl', name, '--name', 'SATA', '--add', 'sata', '--controller', 'IntelAhci')
    vbox('storageattach', name, '--storagectl', 'SATA', '--port', '0', '--device', '0', '--type', 'hdd', '--medium', disk)
    vbox('storageattach', name, '--storagectl', 'SATA', '--port', '1', '--device', '0', '--type', 'dvddrive', '--medium', seed)
    vbox('startvm', name, '--type', 'headless')
