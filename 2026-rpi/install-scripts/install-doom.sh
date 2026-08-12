#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  printf 'Run this script as root, for example: sudo %s\n' "$0" >&2
  exit 1
fi

install_dir="${DOOM_DIR:-/opt/raspberry-pi-workshop/doom}"
compose_source="${DOOM_COMPOSE_FILE:-$(dirname -- "$0")/docker-compose-doom.yml}"
wad_url="https://github.com/nneonneo/universal-doom/raw/refs/heads/main/DOOM1.WAD"

if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
  printf 'Docker and the Docker Compose plugin are required. Run install-docker.sh first.\n' >&2
  exit 1
fi

if [[ ! -f "${compose_source}" ]]; then
  printf 'Compose file not found: %s\n' "${compose_source}" >&2
  exit 1
fi

if [[ "$(uname -m)" != 'x86_64' ]]; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y qemu-user-static binfmt-support
  systemctl restart systemd-binfmt.service 2>/dev/null || true
fi

install -d -m 0755 "${install_dir}"
install -m 0644 "${compose_source}" "${install_dir}/docker-compose.yml"
curl -fL "${wad_url}" -o "${install_dir}/doom1.wad"
chmod 0644 "${install_dir}/doom1.wad"

cd "${install_dir}"
docker compose pull
docker compose up -d --force-recreate

for _ in {1..30}; do
  container_status="$(docker inspect --format '{{.State.Status}}' doom 2>/dev/null || true)"
  [[ "${container_status}" == 'running' ]] && break
  sleep 1
done

sleep 3
container_status="$(docker inspect --format '{{.State.Status}}' doom 2>/dev/null || true)"
if [[ "${container_status:-}" != 'running' ]]; then
  printf 'Doom failed to start. Recent container logs:\n' >&2
  docker logs --tail 50 doom >&2 || true
  exit 1
fi

raspberry_pi_ip="$(hostname -I | cut -d ' ' -f 1)"
printf 'Doom is available at http://%s:8081\n' "${raspberry_pi_ip:-<raspberry-pi-ip>}"
