#!/usr/bin/env bash
# 01 - Users, Groups, Sudo
# RHCSA-LabForge — run as root/sudo
set -euo pipefail

echo "[*] Creating group sysadmins..."
getent group sysadmins >/dev/null || groupadd sysadmins

echo "[*] Creating user devops..."
if ! id devops &>/dev/null; then
    useradd -m -d /home/devops -s /bin/bash -c "DevOps Service Account" devops
fi
usermod -aG sysadmins devops

echo "[*] Setting password aging policy (max 90 days, warn 7 days)..."
chage -M 90 -W 7 devops

echo "[*] Granting scoped sudo to sysadmins group..."
cat > /etc/sudoers.d/sysadmins <<'EOF'
%sysadmins ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart httpd, /usr/bin/systemctl status httpd
EOF
chmod 440 /etc/sudoers.d/sysadmins
visudo -c -f /etc/sudoers.d/sysadmins

echo "[+] Done. Verify with: id devops && sudo -l -U devops"
