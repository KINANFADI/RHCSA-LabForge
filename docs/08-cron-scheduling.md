# 08 — cron / at Scheduling

## RHCSA Objectives Covered
- Schedule tasks using at and cron
- Start and stop virtual machines / manage recurring jobs (context-dependent on exam version)

## cron — recurring jobs
```bash
crontab -e                       # edit current user's crontab
crontab -l                       # list
crontab -u devops -e             # edit another user's crontab (needs root)
```
Format: `minute hour day month weekday command`
```
# Run backup every day at 2:30 AM
30 2 * * *  /usr/local/bin/backup.sh

# Every 15 minutes
*/15 * * * *  /usr/local/bin/healthcheck.sh

# Every Monday at 9am
0 9 * * 1  /usr/local/bin/weekly-report.sh
```

System-wide cron (no user context needed, runs as root by default):
```bash
/etc/cron.d/mytask
/etc/cron.daily/  /etc/cron.weekly/  /etc/cron.monthly/   # drop-in script directories
```

## Restricting cron access
```bash
echo devops >> /etc/cron.allow    # if cron.allow exists, ONLY listed users may use cron
echo baduser >> /etc/cron.deny    # otherwise cron.deny blocks specific users
```

## at — one-time future jobs
```bash
systemctl enable --now atd

echo "/usr/local/bin/cleanup.sh" | at 23:00
at now + 10 minutes
atq                                # list pending jobs
atrm 3                             # remove job by ID
```

## systemd timers (modern alternative, RHCSA-relevant to know)
`/etc/systemd/system/backup.timer`:
```ini
[Timer]
OnCalendar=*-*-* 02:30:00
Persistent=true

[Install]
WantedBy=timers.target
```
```bash
systemctl enable --now backup.timer
systemctl list-timers
```

## Common Exam Traps
- Editing `/var/spool/cron/<user>` directly instead of `crontab -e` — works but is fragile and not the expected method.
- Forgetting `atd` isn't always running by default — `at` jobs silently never fire if the service is down.
- Confusing `cron.allow`/`cron.deny` precedence: if `cron.allow` exists, it's the **only** list that matters — `cron.deny` is ignored.

## Verification
```bash
crontab -l -u devops
atq
systemctl list-timers --all
```
