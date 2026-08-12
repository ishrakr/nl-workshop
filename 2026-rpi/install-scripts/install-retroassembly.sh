#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  printf 'Run this script as root, for example: sudo %s\n' "$0" >&2
  exit 1
fi

install_dir="${RETROASSEMBLY_DIR:-/opt/raspberry-pi-workshop/retroassembly}"
compose_source="${RETROASSEMBLY_COMPOSE_FILE:-$(dirname -- "$0")/docker-compose-retroassembly.yml}"

if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
  printf 'Docker and the Docker Compose plugin are required. Run install-docker.sh first.\n' >&2
  exit 1
fi

if [[ ! -f "${compose_source}" ]]; then
  printf 'Compose file not found: %s\n' "${compose_source}" >&2
  exit 1
fi

install -d -m 0755 "${install_dir}/data"
install -m 0644 "${compose_source}" "${install_dir}/docker-compose.yml"

cd "${install_dir}"
docker compose pull
docker compose up -d --force-recreate

for _ in {1..30}; do
  container_status="$(docker inspect --format '{{.State.Status}}' retroassembly 2>/dev/null || true)"
  [[ "${container_status}" == 'running' ]] && break
  sleep 1
done

sleep 3
container_status="$(docker inspect --format '{{.State.Status}}' retroassembly 2>/dev/null || true)"
if [[ "${container_status:-}" != 'running' ]]; then
  printf 'RetroAssembly failed to start. Recent container logs:\n' >&2
  docker logs --tail 50 retroassembly >&2 || true
  exit 1
fi

raspberry_pi_ip="$(hostname -I | cut -d ' ' -f 1)"
printf 'RetroAssembly is available at http://%s:8000\n' "${raspberry_pi_ip:-<raspberry-pi-ip>}"
printf 'Game data, ROMs, and save states are stored in %s/data.\n' "${install_dir}"
