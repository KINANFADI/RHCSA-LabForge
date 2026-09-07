# Lab Architecture

This renders natively on GitHub (Mermaid support built into markdown preview).

```mermaid
flowchart TB
    subgraph Host["Lab Host / VM (RHEL 9)"]
        A[Users & Groups]
        B[LVM Storage]
        C[SELinux - Enforcing]
        D[firewalld]
        E[SSH - key only, port 2222]
        F[systemd services]
        G[Docker Engine]
        H[Security Hardening<br/>auditd + fail2ban + sysctl]
    end

    subgraph Containers["Docker Containers"]
        G --> C1[web - nginx]
        G --> C2[api]
        G --> C3[db]
    end

    Client[Your Workstation] -- "ssh -p 2222" --> E
    E --> Host
```

## Network layout

| Host | Role | IP | SSH Port |
|---|---|---|---|
| rhcsa-lab | Single lab VM | 192.168.56.11 | 2222 (hardened) |

Built and tested in VirtualBox/KVM using a host-only or NAT network. This is a single-node lab by design — the focus is depth per topic (RHCSA/Linux+/Security+/Docker), not multi-node orchestration.
