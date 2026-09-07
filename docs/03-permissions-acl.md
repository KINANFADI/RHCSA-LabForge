# 03 — Permissions, ACLs, Special Bits

## RHCSA Objectives Covered
- Manage standard ugo/rwx permissions
- Set default permissions with umask
- Configure special permissions: setuid, setgid, sticky bit
- Configure Access Control Lists (ACLs) for complex permission requirements

## Standard Permissions
```bash
chmod 750 /data/reports          # owner rwx, group r-x, others none
chmod u+x,g-w script.sh
chown alice:sysadmins file.txt
umask 0027                        # new files: 640, new dirs: 750 by default
```

## Special Permissions

| Bit | Symbolic | Numeric | Effect |
|---|---|---|---|
| setuid | `chmod u+s` | `4xxx` | Executable runs as the file's **owner**, not the invoking user |
| setgid | `chmod g+s` | `2xxx` | On a dir: new files inherit the **directory's group** (key for shared team dirs) |
| sticky | `chmod +t` | `1xxx` | In a shared dir: users can only delete their **own** files (e.g. `/tmp`) |

```bash
# Shared team directory: group ownership sticks, only owners can delete their own files
mkdir /shared/team
chown root:sysadmins /shared/team
chmod 2770 /shared/team          # setgid + rwx for owner/group
chmod +t /shared/team            # add sticky on top if multiple users write here
```

## ACLs — when ugo isn't enough
```bash
# Give a specific user rwx on a file, beyond normal ownership
setfacl -m u:bob:rwx /data/reports/quarterly.csv

# Give a group read-only
setfacl -m g:auditors:r-- /data/reports/quarterly.csv

# Set a default ACL on a directory so new files inherit it
setfacl -d -m u:bob:rwx /data/reports/

# View
getfacl /data/reports/quarterly.csv

# Remove all ACL entries
setfacl -b /data/reports/quarterly.csv
```
- A `+` at the end of `ls -l` output signals an ACL is present.
- Filesystem must support ACLs and be mounted with `acl` option (default on xfs/ext4 in RHEL 9).

## Common Exam Traps
- Forgetting that `setgid` on a directory affects **new** files only — existing files keep their original group.
- Confusing `-m` (modify/add) with `-x` (remove one entry) with `-b` (remove all) in `setfacl`.
- Default ACLs (`-d`) only apply to a **directory**, and only affect files created **after** they're set.

## Verification
```bash
ls -ld /shared/team
getfacl /data/reports/quarterly.csv
umask
```
