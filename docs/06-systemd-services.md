# 06 — systemd Services & Targets

## RHCSA Objectives Covered
- Start, stop, and check the status of network services
- Configure services to start automatically at boot
- Configure systems to boot into a specific target automatically
- Analyze and diagnose failed boots/services

## Managing Services
```bash
systemctl status sshd
systemctl start sshd
systemctl stop sshd
systemctl restart sshd
systemctl reload sshd            # re-read config without dropping connections (if supported)
systemctl enable sshd            # start at boot
systemctl enable --now sshd      # enable + start in one command
systemctl disable sshd
systemctl is-enabled sshd
systemctl is-active sshd
```

## Boot Targets
```bash
systemctl get-default
systemctl set-default multi-user.target     # boot to CLI (no GUI)
systemctl set-default graphical.target      # boot to GUI

# One-time boot into a different target without changing the default
systemctl isolate rescue.target
```

## Custom Unit File (exam-relevant: writing a simple service)
`/etc/systemd/system/webapp.service`:
```ini
[Unit]
Description=Sample Web App
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/webapp
Restart=on-failure
User=webapp

[Install]
WantedBy=multi-user.target
```
```bash
systemctl daemon-reload           # required after creating/editing a unit file
systemctl enable --now webapp
```

## Diagnosing Failed Boots/Services
```bash
systemctl --failed                       # list everything that failed
journalctl -xeu sshd                     # detailed logs for one unit
journalctl -b                            # logs since last boot
journalctl -b -1                         # logs from the previous boot
systemctl list-dependencies multi-user.target
```

## Common Exam Traps
- Editing a `.service` file and forgetting `systemctl daemon-reload` — systemd keeps using the old cached unit definition.
- `enable` does not `start` a service (and vice versa) — they're independent; `enable --now` does both.
- Setting the wrong default target (`rescue.target` as default) can leave the system unbootable in a normal sense — always verify with `systemctl get-default` before rebooting.

## Verification
```bash
systemctl get-default
systemctl is-enabled sshd
systemctl --failed
```

See [`ansible/roles/systemd_services`](../ansible/roles/systemd_services) for the automated equivalent.
