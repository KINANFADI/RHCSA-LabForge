# 07 — SSH Key-Only Hardening

## RHCSA Objectives Covered
- Access remote systems using SSH
- Configure key-based authentication for SSH
- Configure additional options described in documentation (custom port, restricted logins)

## Full Flow (client → server)

```bash
# 1. On the client: generate a key pair
ssh-keygen -t ed25519 -C "devops@lab"

# 2. Copy the public key to the server
ssh-copy-id user@server_ip

# 3. Confirm passwordless login works BEFORE touching sshd_config
ssh user@server_ip
```

## Hardening `/etc/ssh/sshd_config` (server side)
```
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
AllowUsers devops sysadmin
```
```bash
sshd -t                          # syntax-check BEFORE restarting — catches typos safely
systemctl restart sshd
```

⚠️ **Never disable password auth from a session where you haven't already verified key login works.** If sshd restarts with a bad config or the key isn't in place, you lock yourself out with no fallback (unless you have console/hypervisor access).

## If a Custom Port Is Set
```bash
# firewalld must allow the new port
firewall-cmd --add-port=2222/tcp --permanent
firewall-cmd --reload

# SELinux must also know sshd is allowed to bind that port
semanage port -a -t ssh_port_t -p tcp 2222

# connect
ssh -p 2222 user@server_ip
```
This is a classic exam trap: changing the SSH port breaks connectivity if you update `sshd_config` but forget **either** the firewalld rule **or** the SELinux port label — both are required independently.

## `~/.ssh/config` for a saved shortcut
```
Host labnode
    HostName 192.168.8.11
    Port 2222
    User devops
    IdentityFile ~/.ssh/id_ed25519
```
```bash
ssh labnode
```

## Common Exam Traps
- Restarting `sshd` without `sshd -t` first — a syntax error can drop the service entirely.
- Forgetting the SELinux port context when changing the SSH port (see above) — the service fails to bind even though the config and firewall look correct.
- `AllowUsers` / `DenyUsers` typos silently lock out the intended account.

## Verification
```bash
sshd -t
systemctl status sshd
ss -tnl | grep 2222
ssh -p 2222 -o PreferredAuthentications=password user@server_ip   # should be REFUSED after hardening
```

See [`scripts/07-ssh-harden.sh`](../scripts/07-ssh-harden.sh) and [`ansible/roles/ssh_hardening`](../ansible/roles/ssh_hardening).
