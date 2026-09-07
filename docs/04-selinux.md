# 04 — SELinux

## RHCSA Objectives Covered
- Set enforcing and permissive modes
- List and identify file/process SELinux contexts
- Restore default file contexts
- Use boolean settings to modify system SELinux settings
- Diagnose and address SELinux policy violations

## Modes
```bash
getenforce                      # current runtime mode
setenforce 0                    # Permissive (logs but doesn't block) - temporary, resets on reboot
setenforce 1                    # Enforcing

# Persistent change: /etc/selinux/config
sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
```

## File Contexts
```bash
ls -Z /var/www/html                    # view context
semanage fcontext -l | grep httpd      # list policy rules for a service

# Serving web content from a non-standard directory
mkdir -p /web/mysite
semanage fcontext -a -t httpd_sys_content_t "/web/mysite(/.*)?"
restorecon -Rv /web/mysite
```
- `chcon` changes context temporarily (lost on `restorecon` or relabel).
- `semanage fcontext` + `restorecon` is the **persistent** way — always prefer this for anything that survives a relabel.

## Booleans (toggle policy behavior without writing custom policy)
```bash
getsebool -a | grep httpd
setsebool -P httpd_can_network_connect on     # -P = persistent across reboot
```

## Diagnosing Denials
```bash
ausearch -m avc -ts recent
sealert -a /var/log/audit/audit.log     # human-readable explanation + suggested fix
```
Typical workflow when a service unexpectedly fails ("permission denied" but ugo/rwx looks fine):
1. `getenforce` → confirm it's actually SELinux (Enforcing).
2. `ausearch -m avc -ts recent` → find the denial.
3. Fix with the *narrowest* mechanism: boolean if one exists, `semanage fcontext` + `restorecon` if it's a context issue.
4. **Never** disable SELinux to "fix" it — that's an automatic exam-fail habit and a real-world security anti-pattern.

## Common Exam Traps
- Editing `/etc/selinux/config` doesn't affect the running system until reboot — use `setenforce` for immediate effect, edit the config for persistence, do both.
- Forgetting `restorecon` after `semanage fcontext -a` — the policy rule alone doesn't relabel existing files.
- Reaching for `chcon` when the task says "make it survive a reboot/relabel" — that's a `semanage` job.

## Verification
```bash
getenforce
ls -Z /web/mysite
getsebool httpd_can_network_connect
```

See [`scripts/04-selinux-config.sh`](../scripts/04-selinux-config.sh) and [`ansible/roles/selinux`](../ansible/roles/selinux).
