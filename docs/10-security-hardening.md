# 10 — Security Hardening (Security+ Aligned)

This module maps Linux system hardening tasks to CompTIA Security+ domains: access control, cryptography, host hardening, monitoring/auditing, and vulnerability management.

## 1. Access Control (AAA — Authentication, Authorization, Accounting)

```bash
# Enforce strong password complexity (PAM)
# /etc/security/pwquality.conf
minlen = 12
minclass = 3
maxrepeat = 3

# Lock an account after failed login attempts (pam_faillock)
# /etc/pam.d/system-auth or /etc/security/faillock.conf
deny = 5
unlock_time = 900

faillock --user devops        # view failed attempt history
faillock --user devops --reset
```

**Accounting** — every privileged action should be attributable:
```bash
last              # recent logins
lastb             # failed login attempts
who
w
```

## 2. Cryptography

```bash
# Verify TLS certificate on a service
openssl s_client -connect example.com:443 -servername example.com </dev/null

# Generate a self-signed cert for internal lab TLS
openssl req -x509 -nodes -newkey rsa:4096 \
  -keyout lab.key -out lab.crt -days 365 \
  -subj "/CN=lab.local"

# File integrity hashing
sha256sum critical-config.conf > critical-config.conf.sha256
sha256sum -c critical-config.conf.sha256    # verify it hasn't changed
```

## 3. Host Hardening

```bash
# Disable unused services — reduce attack surface
systemctl list-unit-files --state=enabled
systemctl disable --now cups        # example: disable printing if unused

# Remove unnecessary packages
dnf list installed | grep telnet    # telnet should NOT be present
dnf remove -y telnet-server

# Kernel hardening via sysctl
# /etc/sysctl.d/99-hardening.conf
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
kernel.randomize_va_space = 2
sysctl --system
```

## 4. Monitoring & Auditing

```bash
# auditd — track access to sensitive files
systemctl enable --now auditd
auditctl -w /etc/passwd -p wa -k passwd_changes
auditctl -w /etc/shadow -p wa -k shadow_changes
ausearch -k passwd_changes

# Persistent audit rules
# /etc/audit/rules.d/audit.rules
-w /etc/passwd -p wa -k passwd_changes

# Centralized log review
journalctl -p err -b            # errors since boot
journalctl _COMM=sshd           # filter by process
```

## 5. Network-Facing Hardening (ties to module 05)

```bash
# Fail2ban — block repeated failed SSH attempts (common Security+ topic)
dnf install -y fail2ban
systemctl enable --now fail2ban

# /etc/fail2ban/jail.local
[sshd]
enabled = true
port = 2222
maxretry = 3
bantime = 3600
```

## 6. Vulnerability Management

```bash
# Check for available security updates only
dnf updateinfo list security

# Apply security patches
dnf update --security -y

# Scan for CVEs in container images (ties to module 09)
# trivy image nginx:latest
```

## Threat Model Summary (why each control matters)

| Control | Threat it mitigates |
|---|---|
| Password complexity + faillock | Brute-force / credential stuffing |
| SELinux enforcing | Privilege escalation via compromised process |
| firewalld least-privilege rules | Unnecessary exposed attack surface |
| SSH key-only + non-default port | Automated SSH brute-force bots |
| auditd on `/etc/passwd`, `/etc/shadow` | Undetected unauthorized account changes |
| fail2ban | Repeated authentication attacks |
| `dnf update --security` | Known CVEs / unpatched vulnerabilities |
| Non-root container users | Container breakout escalating to host root |

## Verification
```bash
faillock --user devops
auditctl -l
fail2ban-client status sshd
dnf updateinfo list security | head
sysctl net.ipv4.conf.all.accept_redirects
```

See [`scripts/10-security-hardening.sh`](../scripts/10-security-hardening.sh).
