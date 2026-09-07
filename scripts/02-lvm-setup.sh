#!/usr/bin/env bash
# 02 - LVM storage setup
# RHCSA-LabForge — run as root/sudo
# WARNING: Edit DISK below to point at a real, empty disk/partition in your lab VM.
set -euo pipefail

DISK="${1:-/dev/sdb1}"       # pass the target partition as an argument, or edit here
VG_NAME="vg_data"
LV_NAME="lv_app"
LV_SIZE="2G"
MOUNT_POINT="/app"

echo "[*] Creating physical volume on ${DISK}..."
pvcreate "${DISK}"

echo "[*] Creating volume group ${VG_NAME}..."
vgcreate "${VG_NAME}" "${DISK}"

echo "[*] Creating logical volume ${LV_NAME} (${LV_SIZE})..."
lvcreate -L "${LV_SIZE}" -n "${LV_NAME}" "${VG_NAME}"

echo "[*] Formatting with XFS..."
mkfs.xfs "/dev/${VG_NAME}/${LV_NAME}"

echo "[*] Mounting at ${MOUNT_POINT}..."
mkdir -p "${MOUNT_POINT}"
mount "/dev/${VG_NAME}/${LV_NAME}" "${MOUNT_POINT}"

UUID=$(blkid -s UUID -o value "/dev/${VG_NAME}/${LV_NAME}")
if ! grep -q "${UUID}" /etc/fstab; then
    echo "UUID=${UUID}  ${MOUNT_POINT}  xfs  defaults  0 0" >> /etc/fstab
fi

echo "[*] Validating /etc/fstab..."
mount -a

echo "[+] Done. Verify with: lsblk && df -hT ${MOUNT_POINT}"
