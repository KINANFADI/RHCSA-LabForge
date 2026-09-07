#!/usr/bin/env bash
# 05 - firewalld configuration
# RHCSA-LabForge — run as root/sudo
set -euo pipefail

echo "[*] Ensuring firewalld is running..."
systemctl enable --now firewalld

ZONE="public"

echo "[*] Opening http/https services (runtime + permanent)..."
for svc in http https; do
    firewall-cmd --zone="${ZONE}" --add-service="${svc}"
    firewall-cmd --zone="${ZONE}" --add-service="${svc}" --permanent
done

echo "[*] Opening custom app port 8080/tcp..."
firewall-cmd --zone="${ZONE}" --add-port=8080/tcp
firewall-cmd --zone="${ZONE}" --add-port=8080/tcp --permanent

echo "[*] Reloading to confirm permanent config matches runtime..."
firewall-cmd --reload

echo "[+] Done. Verify with: firewall-cmd --zone=${ZONE} --list-all"
