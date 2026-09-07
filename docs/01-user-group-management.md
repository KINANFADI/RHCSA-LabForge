# 01 — User & Group Management

## RHCSA Objectives Covered
- Create, delete, and modify local user accounts
- Change passwords and adjust password aging
- Create, delete, and modify local groups and group memberships
- Configure superuser access (sudo)

## Key Concepts

| File | Purpose |
|---|---|
| `/etc/passwd` | User account records (UID, GID, home, shell) |
| `/etc/shadow` | Encrypted passwords + aging policy |
| `/etc/group` | Group definitions and membership |
| `/etc/login.defs` | Default UID/GID ranges, password aging defaults |
| `/etc/sudoers`, `/etc/sudoers.d/` | Sudo privilege rules — **always edit with `visudo`** |

## Commands

```bash
# Create a user with a specific UID, home dir, and shell
useradd -u 1500 -m -d /home/devops -s /bin/bash devops

# Set / change password
passwd devops

# Force password change at next login
chage -d 0 devops

# Set password aging: max 90 days, warn 7 days before expiry
chage -M 90 -W 7 devops

# Create a group, then add secondary membership
groupadd sysadmins
usermod -aG sysadmins devops        # -a is critical: append, don't replace

# Lock / unlock an account
passwd -l devops
passwd -u devops

# Delete a user and their home directory
userdel -r devops
```

## Sudo Configuration

```bash
visudo -f /etc/sudoers.d/sysadmins
```
```
%sysadmins ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart httpd, /usr/bin/systemctl status httpd
```
- `%group` syntax applies to everyone in that group.
- Scope commands as tightly as possible — never hand out blanket `ALL=(ALL) ALL` unless intentional.
- `visudo` locks the file and syntax-checks on save; editing sudoers with `vim` directly risks a broken file that locks out sudo entirely.

## Common Exam Traps
- `usermod -G` **without** `-a` wipes all existing secondary groups — always pair with `-a` unless you mean to replace.
- Forgetting `-m` on `useradd` when a home directory is expected.
- UID/GID ranges: system accounts vs regular users are split in `/etc/login.defs` (`UID_MIN` / `UID_MAX`) — matters for compliance-style tasks ("create a user with UID between X and Y").

## Verification
```bash
id devops
groups devops
chage -l devops
sudo -l -U devops
```

See [`scripts/01-users-groups.sh`](../scripts/01-users-groups.sh) for the runnable version and [`ansible/roles/users`](../ansible/roles/users) for the automated, idempotent equivalent.
