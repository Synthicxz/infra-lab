# Micro PC Baseline

## Host Identity

OS: Arch Linux
Hostname: archbox
Hardware: Intel NUC10i5FNK
Main LAN IP: 192.168.1.240
Main interface: eno1
SSH user: jordan
SSH command: ssh jordan@192.168.1.240

## Access Safety

SSH is working over normal LAN.
SSH connection observed from 192.168.1.232 to 192.168.1.240:22.

## Cleaned Old Lab Artifacts

Removed old Docker stack:
- portainer
- nginx
- nextcloud
- nextcloud-db
- hello-world container

Removed old Docker data:
- nextcloud_data
- nextcloud_pgdata
- portainer_data
- old images
- old custom Docker network: homelab

Removed old WireGuard/VPN setup:
- wg0 NetworkManager connection removed
- wg0 interface no longer present
- /etc/wireguard is empty
- old client/server key files removed from home directory

Removed old VM:
- friend-dev VM undefined from system libvirt
- NVRAM removed
- VM disk removed:
  - /var/lib/libvirt/images/friend-dev-2.qcow2
- orphaned VM disks removed:
  - /var/lib/libvirt/images/friend-dev.qcow2
  - /var/lib/libvirt/images/friend-dev-1.qcow2

Removed old home folders:
- ~/iso
- ~/nginx

## Current Docker State

Containers: none
Volumes: none
Networks:
- bridge
- host
- none

Docker and containerd remain installed for future lab work.

## Current Libvirt State

Registered VMs: none
Libvirt default network:
- default active
- autostart yes
- persistent yes

Listening libvirt services:
- dnsmasq on 192.168.122.1:53
- dnsmasq DHCP on virbr0:67

These are expected for the default NAT VM network.

## Current Listening Ports

Expected:
- SSH on 0.0.0.0:22
- SSH on [::]:22
- libvirt DNS/DHCP on 192.168.122.1 / virbr0
- containerd local-only on 127.0.0.1

Confirmed absent:
- no port 80
- no port 443

## Baseline Conclusion

The host is clean enough to begin the new CloudOps homelab.

Next phase:
Create one clean manual VM before automating VM creation with Terraform.
