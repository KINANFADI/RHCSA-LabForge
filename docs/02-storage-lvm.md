# 02 — Storage: Partitions, LVM, Swap, autofs

## RHCSA Objectives Covered
- List, create, and delete partitions on MBR/GPT disks
- Create and remove physical volumes, volume groups, logical volumes
- Configure systems to mount file systems at boot by UUID or label
- Add new partitions/logical volumes, and swap
- Configure autofs / NFS mounts on demand

## Layered Model

```
Physical Disk (/dev/sdb)
   └── Partition (/dev/sdb1)  [type: 8e / Linux LVM]
        └── Physical Volume (PV)
             └── Volume Group (VG)
                  └── Logical Volume (LV)
                       └── Filesystem (xfs/ext4)
                            └── Mount point
```

## Commands

```bash
# Partition a disk (or use gdisk/fdisk interactively for GPT/MBR)
parted /dev/sdb --script mklabel gpt mkpart primary 0% 100%

# Build the LVM stack
pvcreate /dev/sdb1
vgcreate vg_data /dev/sdb1
lvcreate -L 2G -n lv_app vg_data

# Filesystem + mount
mkfs.xfs /dev/vg_data/lv_app
mkdir -p /app
mount /dev/vg_data/lv_app /app

# Persistent mount — use UUID, not /dev/sdX (device names aren't guaranteed stable)
blkid /dev/vg_data/lv_app
echo 'UUID=<uuid-here>  /app  xfs  defaults  0 0' >> /etc/fstab
mount -a          # test fstab syntax before rebooting
```

## Extending a Logical Volume (online, no downtime)
```bash
vgextend vg_data /dev/sdc1
lvextend -L +1G /dev/vg_data/lv_app
xfs_growfs /app          # for xfs (ext4 uses resize2fs instead)
```

## Swap
```bash
lvcreate -L 512M -n lv_swap vg_data
mkswap /dev/vg_data/lv_swap
swapon /dev/vg_data/lv_swap
echo '/dev/vg_data/lv_swap  swap  swap  defaults  0 0' >> /etc/fstab
```

## autofs (mount-on-demand)
```bash
dnf install -y autofs
# /etc/auto.master
echo '/mnt/auto  /etc/auto.misc' >> /etc/auto.master
# /etc/auto.misc
echo 'data  -rw,soft  server:/exports/data' >> /etc/auto.misc
systemctl enable --now autofs
```
Accessing `/mnt/auto/data` triggers the mount automatically; it unmounts after an idle timeout.

## Common Exam Traps
- Forgetting `mount -a` to validate `/etc/fstab` before reboot — a bad entry can drop you to emergency mode.
- Using device paths (`/dev/sdb1`) instead of `UUID=` in fstab.
- `xfs` cannot be shrunk — only grown. Plan LV sizing accordingly, or use `ext4` if shrink capability matters.
- Not removing a volume from `/etc/fstab` before deleting it — causes boot failures.

## Verification
```bash
lsblk
pvs; vgs; lvs
df -hT /app
findmnt /app
swapon --show
```

See [`scripts/02-lvm-setup.sh`](../scripts/02-lvm-setup.sh) and [`ansible/roles/storage`](../ansible/roles/storage).
