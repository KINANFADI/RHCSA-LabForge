#!/usr/bin/env bash
# verify-all.sh — sanity-check every RHCSA-LabForge module
# RHCSA-LabForge — run as root/sudo
set -uo pipefail

PASS=0
FAIL=0

check() {
    local desc="$1"; shift
    if "$@" &>/dev/null; then
        echo "[PASS] ${desc}"
        ((PASS++))
    else
        echo "[FAIL] ${desc}"
        ((FAIL++))
    fi
}

echo "== Users & Groups =="
check "user devops exists"        id devops
check "group sysadmins exists"    getent group sysadmins

echo "== Storage =="
check "vg_data volume group exists" vgdisplay vg_data
check "/app is mounted"           findmnt /app

echo "== SELinux =="
check "SELinux is enforcing"      bash -c '[ "$(getenforce)" = "Enforcing" ]'

echo "== firewalld =="
check "firewalld is active"       systemctl is-active --quiet firewalld
check "http service is open"      bash -c 'firewall-cmd --zone=public --list-services | grep -qw http'

echo "== SSH =="
check "sshd is active"            systemctl is-active --quiet sshd
check "PasswordAuthentication disabled" bash -c 'grep -qi "^PasswordAuthentication no" /etc/ssh/sshd_config'

echo "== Docker =="
check "docker service is active"  systemctl is-active --quiet docker

echo "== Security Hardening =="
check "auditd is active"          systemctl is-active --quiet auditd
check "fail2ban is active"        systemctl is-active --quiet fail2ban

echo
echo "================================"
echo " Passed: ${PASS}   Failed: ${FAIL}"
echo "================================"

[[ ${FAIL} -eq 0 ]]
