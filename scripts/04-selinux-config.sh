#!/usr/bin/env bash
# 04 - SELinux: enforcing mode, custom web content context
# RHCSA-LabForge — run as root/sudo
set -euo pipefail

echo "[*] Ensuring SELinux is Enforcing (persistent + runtime)..."
sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
setenforce 1 || echo "[!] Already enforcing or requires reboot to apply."

WEBDIR="/web/mysite"
echo "[*] Setting up custom web content directory at ${WEBDIR}..."
mkdir -p "${WEBDIR}"
echo "<h1>RHCSA-LabForge test page</h1>" > "${WEBDIR}/index.html"

echo "[*] Applying persistent SELinux context (httpd_sys_content_t)..."
semanage fcontext -a -t httpd_sys_content_t "${WEBDIR}(/.*)?" 2>/dev/null || \
    semanage fcontext -m -t httpd_sys_content_t "${WEBDIR}(/.*)?"
restorecon -Rv "${WEBDIR}"

echo "[*] Enabling httpd_can_network_connect boolean (persistent)..."
setsebool -P httpd_can_network_connect on

echo "[+] Done. Verify with: getenforce && ls -Z ${WEBDIR} && getsebool httpd_can_network_connect"
