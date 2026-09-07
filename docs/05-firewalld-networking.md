# 05 — firewalld & Networking (nmcli)

## RHCSA Objectives Covered
- Configure IPv4/IPv6 addresses, static routing, hostname resolution
- Configure firewall settings using firewall-cmd / firewalld
- Manage network connections with nmcli / NetworkManager

## Networking with nmcli
```bash
nmcli connection show
nmcli device status

# Static IP on an existing connection
nmcli connection modify eth0 ipv4.addresses 192.168.8.50/24
nmcli connection modify eth0 ipv4.gateway 192.168.8.1
nmcli connection modify eth0 ipv4.dns "8.8.8.8 1.1.1.1"
nmcli connection modify eth0 ipv4.method manual
nmcli connection up eth0

# Static hostname
hostnamectl set-hostname node1.lab.local
```

## Hostname Resolution
```bash
# /etc/hosts - checked before DNS
192.168.8.50   node1.lab.local   node1

# /etc/resolv.conf is managed by NetworkManager when using nmcli-configured DNS —
# don't hand-edit it directly if NetworkManager owns the interface, or your edits
# get overwritten on the next connection reload.
```

## firewalld
```bash
firewall-cmd --state
firewall-cmd --get-active-zones
firewall-cmd --get-default-zone

# Open a service by name (uses predefined XML service definitions)
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent

# Open a raw port
firewall-cmd --zone=public --add-port=8080/tcp --permanent

# Apply the changes (permanent rules don't affect the live runtime until reloaded)
firewall-cmd --reload

# Verify
firewall-cmd --zone=public --list-all
```

## Port Forwarding (common exam scenario)
```bash
firewall-cmd --zone=public --add-forward-port=port=2222:proto=tcp:toport=22 --permanent
firewall-cmd --reload
```

## Common Exam Traps
- Running a command **without** `--permanent`, then rebooting/reloading and losing the rule — always pair a `--permanent` change with `--reload`, or make the same change to both runtime and permanent if you need it immediately AND after reboot:
  ```bash
  firewall-cmd --zone=public --add-service=http           # runtime, immediate
  firewall-cmd --zone=public --add-service=http --permanent  # survives reload/reboot
  ```
- Confusing zones — a rule added to the wrong zone silently does nothing if the interface isn't in that zone (`firewall-cmd --get-zone-of-interface=eth0`).
- Forgetting `nmcli connection up` after `modify` — changes stage but don't apply until the connection is brought back up.

## Verification
```bash
ip addr show
nmcli connection show eth0
firewall-cmd --zone=public --list-all
ss -tnl
```

See [`scripts/05-firewalld-setup.sh`](../scripts/05-firewalld-setup.sh) and [`ansible/roles/firewall`](../ansible/roles/firewall).
