# 09 — Docker Concepts

Docker isn't on the RHCSA exam, but it's core CompTIA Linux+ material and a near-universal real-world skill. This module covers the concepts and commands worth knowing cold.

## Core Concepts

| Term | What it means |
|---|---|
| Image | Read-only template (layers) used to create containers |
| Container | A running (or stopped) instance of an image — isolated process with its own filesystem view, network namespace, PID namespace |
| Dockerfile | Instructions to build an image |
| Registry | Where images are stored/pulled from (Docker Hub, private registries) |
| Volume | Persistent storage that outlives a container's lifecycle |
| Network | Virtual network connecting containers (bridge, host, none, overlay) |
| Namespace | Kernel feature providing isolation (PID, net, mount, UTS, IPC, user) |
| cgroups | Kernel feature that limits/accounts for resource usage (CPU, memory) per container |

Containers are **not** VMs — they share the host kernel and get isolation via namespaces + cgroups, not full hardware virtualization. This is why they're lighter and start faster, and also why a kernel-level exploit can be more dangerous (weaker isolation boundary than a hypervisor).

## Basic Lifecycle
```bash
docker pull nginx:latest
docker images
docker inspect nginx:latest

docker run -d --name web -p 8080:80 nginx:latest
docker ps
docker ps -a
docker logs web
docker exec -it web /bin/bash      # shell into a running container
docker stop web
docker start web
docker rm web
docker rmi nginx:latest
```

## Dockerfile Basics
```dockerfile
FROM registry.access.redhat.com/ubi9/ubi-minimal
RUN microdnf install -y httpd && microdnf clean all
COPY index.html /var/www/html/index.html
EXPOSE 80
CMD ["httpd", "-D", "FOREGROUND"]
```
```bash
docker build -t mysite:1.0 .
docker run -d -p 8080:80 mysite:1.0
```
Layers are cached — reordering instructions so rarely-changing steps (installing packages) come before frequently-changing ones (copying app code) speeds up rebuilds significantly.

## Persistent Storage
```bash
docker volume create webdata
docker run -d -v webdata:/var/www/html -p 8080:80 nginx
docker volume inspect webdata
```
Bind mount (host path directly, not managed by Docker):
```bash
docker run -d -v /srv/webdata:/var/www/html:Z -p 8080:80 nginx
```
`:Z` relabels for SELinux, same purpose as with Podman.

## Networking
```bash
docker network ls
docker network create app-net
docker run -d --network app-net --name db postgres:16
docker run -d --network app-net --name api myapi:1.0   # can reach 'db' by name
```

## docker-compose (multi-container apps)
```yaml
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    depends_on:
      - api
  api:
    build: ./api
    environment:
      - DB_HOST=db
  db:
    image: postgres:16
    volumes:
      - dbdata:/var/lib/postgresql/data

volumes:
  dbdata:
```
```bash
docker compose up -d
docker compose ps
docker compose down
```

## Security Notes (ties into Security+ module)
- Never run containers as root inside the container unless required — set a `USER` in the Dockerfile.
- Don't bake secrets (passwords, API keys) into images — they persist in image layers even if "deleted" in a later layer. Use environment variables injected at runtime, or a secrets manager.
- Scan images for known CVEs before deploying: `docker scout cves nginx:latest` (or Trivy/Clair as alternatives).
- Limit resources to prevent a compromised/runaway container from starving the host:
  ```bash
  docker run -d --memory=512m --cpus=1 nginx
  ```
- Prefer minimal base images (`ubi-minimal`, `alpine`) — smaller attack surface, fewer packages to patch.

## Common Pitfalls
- Forgetting `-d` (detached) and wondering why the terminal hangs.
- Mapping ports backwards — `-p HOST:CONTAINER`, not the reverse.
- Assuming `docker stop` frees disk space — stopped containers and unused images/volumes still consume disk until pruned:
  ```bash
  docker system prune -a --volumes
  ```

## Verification
```bash
docker ps
docker inspect web --format '{{.NetworkSettings.IPAddress}}'
docker exec web curl -s localhost
```

See [`scripts/09-docker-basics.sh`](../scripts/09-docker-basics.sh).
