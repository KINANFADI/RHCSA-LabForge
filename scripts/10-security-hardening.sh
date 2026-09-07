#!/usr/bin/env bash
# 10 - Security+ aligned baseline hardening
# RHCSA-LabForge — run as root/sudo
set -euo pipefail

echo "[*] Enforcing password complexity policy..."
if ! grep -q "^minlen" /etc/security/pwquality.conf 2>/dev/null; then
    {
        echo "minlen = 12"
        echo "minclass = 3"
        echo "maxrepeat = 3"
    } >> /etc/security/pwquality.conf
fi

echo "[*] Configuring account lockout after failed attempts..."
mkdir -p /etc/security
if ! grep -q "^deny" /etc/security/faillock.conf 2>/dev/null; then
    {
        echo "deny = 5"
        echo "unlock_time = 900"
    } >> /etc/security/faillock.conf
fi

echo "[*] Applying kernel network hardening via sysctl..."
cat > /etc/sysctl.d/99-hardening.conf <<'EOF'
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
kernel.randomize_va_space = 2
EOF
sysctl --system

echo "[*] Enabling auditd and watching sensitive files..."
systemctl enable --now auditd
auditctl -w /etc/passwd -p wa -k passwd_changes 2>/dev/null || true
auditctl -w /etc/shadow -p wa -k shadow_changes 2>/dev/null || true
mkdir -p /etc/audit/rules.d
grep -q "/etc/passwd" /etc/audit/rules.d/audit.rules 2>/dev/null || \
    echo "-w /etc/passwd -p wa -k passwd_changes" >> /etc/audit/rules.d/audit.rules

echo "[*] Installing and enabling fail2ban for SSH..."
dnf install -y fail2ban || true
cat > /etc/fail2ban/jail.local <<'EOF'
[sshd]
enabled = true
maxretry = 3
bantime = 3600
EOF
systemctl enable --now fail2ban || true

echo "[*] Checking for pending security updates (not applying automatically)..."
dnf updateinfo list security || true

echo "[+] Done. Verify with:"
echo "    auditctl -l"
echo "    fail2ban-client status sshd"
echo "    sysctl net.ipv4.conf.all.accept_redirects"
