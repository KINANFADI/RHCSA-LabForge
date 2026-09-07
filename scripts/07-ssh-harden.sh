#!/usr/bin/env bash
# 07 - SSH key-only hardening
# RHCSA-LabForge — run as root/sudo
#
# ⚠️  SAFETY: Do NOT run this until you have confirmed key-based login
#     already works for your account (ssh-copy-id done, tested manually).
#     Running this before that WILL lock you out.
set -euo pipefail

SSHD_CONFIG="/etc/ssh/sshd_config"
NEW_PORT="2222"

read -rp "Have you already confirmed passwordless key login works? (yes/no): " confirm
if [[ "${confirm}" != "yes" ]]; then
    echo "[!] Aborting. Set up ssh-copy-id and test key login first."
    exit 1
fi

cp "${SSHD_CONFIG}" "${SSHD_CONFIG}.bak.$(date +%s)"

echo "[*] Applying hardened settings..."
sed -i "s/^#\?Port .*/Port ${NEW_PORT}/" "${SSHD_CONFIG}"
sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin no/" "${SSHD_CONFIG}"
sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication no/" "${SSHD_CONFIG}"
sed -i "s/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/" "${SSHD_CONFIG}"

echo "[*] Opening new SSH port in firewalld..."
firewall-cmd --add-port="${NEW_PORT}/tcp" --permanent
firewall-cmd --reload

echo "[*] Applying SELinux port label for sshd..."
semanage port -a -t ssh_port_t -p tcp "${NEW_PORT}" 2>/dev/null || \
    echo "[i] Port label may already exist — continuing."

echo "[*] Validating sshd config syntax before restart..."
sshd -t

echo "[*] Restarting sshd..."
systemctl restart sshd

echo "[+] Done. Test in a NEW terminal (keep this session open) with:"
echo "    ssh -p ${NEW_PORT} <user>@<host>"
