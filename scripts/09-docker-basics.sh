#!/usr/bin/env bash
# 09 - Docker fundamentals demo
# RHCSA-LabForge — run as root or a user in the 'docker' group
set -euo pipefail

echo "[*] Pulling nginx image..."
docker pull nginx:latest

echo "[*] Creating a named volume for persistent content..."
docker volume create webdata

echo "[*] Running container 'web' with published port and volume..."
docker rm -f web &>/dev/null || true
docker run -d --name web -p 8080:80 -v webdata:/usr/share/nginx/html nginx:latest

echo "[*] Waiting for container to be healthy..."
sleep 2
docker ps --filter "name=web"

echo "[*] Testing the service..."
curl -sf localhost:8080 >/dev/null && echo "[+] nginx responded successfully."

echo "[+] Done. Verify with: docker ps && docker inspect web"
echo "[i] Clean up with: docker rm -f web && docker volume rm webdata"
