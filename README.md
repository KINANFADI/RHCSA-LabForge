# RHCSA-LabForge

**An enterprise-style RHEL system administration lab covering RHCSA (EX200), CompTIA Linux+, CompTIA Security+, and Docker fundamentals  built as a real, working portfolio project.**

![RHEL](https://img.shields.io/badge/RHEL-9-red?logo=redhat)
![RHCSA](https://img.shields.io/badge/RHCSA-Ready-blue)
![Linux+](https://img.shields.io/badge/CompTIA-Linux%2B-orange)
![Security+](https://img.shields.io/badge/CompTIA-Security%2B-darkred)
![Docker](https://img.shields.io/badge/Containers-Docker-2496ED?logo=docker)
![License](https://img.shields.io/badge/License-MIT-green)

> Built by Knan final-year CS student (UTM), RHCSA/RHCE certified. This repo is hands-on proof-of-work: every topic is documented, scripted, and verifiable not just theory.
---

## Why This Project Exists

Certifications prove you passed an exam. This repo proves you can **actually do the job**:
- Every RHCSA objective + overlapping Linux+ and Security+ topics mapped to a real, working implementation
- Runnable bash scripts, not just command lists in a doc
- A dedicated security-hardening module mapped explicitly to Security+ domains (AAA, cryptography, host hardening, monitoring, vulnerability management)
- A Docker module covering images, volumes, networking, and container security  core Linux+ and real-world DevOps material
- Verification scripts that prove each configuration actually works

## Repository Structure

```
RHCSA-LabForge/
├── README.md
├── docs/                      # one write-up per topic (theory + commands + exam traps)
│   ├── 01-user-group-management.md
│   ├── 02-storage-lvm.md
│   ├── 03-permissions-acl.md
│   ├── 04-selinux.md
│   ├── 05-firewalld-networking.md
│   ├── 06-systemd-services.md
│   ├── 07-ssh-hardening.md
│   ├── 08-cron-scheduling.md
│   ├── 09-docker-fundamentals.md
│   └── 10-security-hardening.md
├── scripts/                   # runnable bash for every module
│   ├── 01-users-groups.sh
│   ├── 02-lvm-setup.sh
│   ├── 04-selinux-config.sh
│   ├── 05-firewalld-setup.sh
│   ├── 07-ssh-harden.sh
│   ├── 09-docker-basics.sh
│   ├── 10-security-hardening.sh
│   └── verify-all.sh          # runs sanity checks across every module
├── assets/
│   ├── images/                # screenshots, terminal captures (PNG/SVG, <1MB each)
│   └── diagrams/architecture.md   # Mermaid diagram, renders on GitHub
└── media/
    └── README.md              # how demo videos/asciinema recordings are linked (not committed)
```

## Topics Covered

| # | Topic | Certifications | Script | Doc |
|---|---|---|---|---|
| 1 | Users, groups, sudo | RHCSA, Linux+ | [`scripts/01`](scripts/01-users-groups.sh) | [docs/01](docs/01-user-group-management.md) |
| 2 | Storage: partitions, LVM, swap | RHCSA, Linux+ | [`scripts/02`](scripts/02-lvm-setup.sh) | [docs/02](docs/02-storage-lvm.md) |
| 3 | Permissions, ACLs, special bits | RHCSA, Linux+ |  | [docs/03](docs/03-permissions-acl.md) |
| 4 | SELinux contexts & booleans | RHCSA | [`scripts/04`](scripts/04-selinux-config.sh) | [docs/04](docs/04-selinux.md) |
| 5 | firewalld & networking (nmcli) | RHCSA, Linux+, Security+ | [`scripts/05`](scripts/05-firewalld-setup.sh) | [docs/05](docs/05-firewalld-networking.md) |
| 6 | systemd services & targets | RHCSA, Linux+ |  | [docs/06](docs/06-systemd-services.md) |
| 7 | SSH key-only hardening | RHCSA, Security+ | [`scripts/07`](scripts/07-ssh-harden.sh) | [docs/07](docs/07-ssh-hardening.md) |
| 8 | cron / at scheduling | RHCSA, Linux+ |  | [docs/08](docs/08-cron-scheduling.md) |
| 9 | Docker: images, volumes, networking, security | Linux+ | [`scripts/09`](scripts/09-docker-basics.sh) | [docs/09](docs/09-docker-fundamentals.md) |
| 10 | Security hardening: AAA, crypto, auditd, fail2ban | Security+ | [`scripts/10`](scripts/10-security-hardening.sh) | [docs/10](docs/10-security-hardening.md) |

## Quick Start

```bash
git clone https://github.com/<your-username>/RHCSA-LabForge.git
cd RHCSA-LabForge/scripts

sudo ./01-users-groups.sh
sudo ./02-lvm-setup.sh          # edit the DISK variable first, or pass as arg
sudo ./04-selinux-config.sh
sudo ./05-firewalld-setup.sh
sudo ./07-ssh-harden.sh         # interactive safety check before it locks anything down
sudo ./09-docker-basics.sh      # requires Docker installed
sudo ./10-security-hardening.sh

sudo ./verify-all.sh
```

Each script is independent run only the modules relevant to what you're studying.

## Architecture

See [`assets/diagrams/architecture.md`](assets/diagrams/architecture.md) for the lab network layout (renders directly on GitHub via Mermaid).

## Screenshots & Demo Videos

- **Screenshots** live in `assets/images/` and are embedded directly in each `docs/*.md` file.
- **Videos are not committed to the repo**  git handles large binaries poorly. Instead:
  1. Record terminal sessions with [asciinema](https://asciinema.org/)  tiny file, playable embed.
  2. Upload full screen recordings to YouTube (unlisted is fine) and link them.
  3. Drag an `.mp4` directly into a README while editing it on github.com  GitHub auto-uploads it to its CDN and gives you a working embed link.
  See [`media/README.md`](media/README.md) for exact conventions.

## Verification Philosophy

```bash
sudo ./scripts/verify-all.sh
```
Checks service states, firewall rules, SELinux mode, LVM layout, SSH config, Docker, auditd, and fail2ban against expected values  exiting non-zero on any drift.

## License

MIT  see [`LICENSE`](LICENSE). Use this as a template for your own certification portfolio.
