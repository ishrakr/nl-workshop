#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  printf 'Run this script as root, for example: sudo %s\n' "$0" >&2
  exit 1
fi

install_dir="${DOOM_DIR:-/opt/raspberry-pi-workshop/doom}"
compose_source="${DOOM_COMPOSE_FILE:-$(dirname -- "$0")/docker-compose-doom.yml}"
asset_base_url="${DOOM_ASSET_BASE_URL:-https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/doom}"
wad_url="https://github.com/nneonneo/universal-doom/raw/refs/heads/main/DOOM1.WAD"
wad_sha256="1d7d43be501e67d927e415e0b8f3e29c3bf33075e859721816f652a526cac771"

asset_names=(default.cfg index.html nginx.conf websockets-doom.js websockets-doom.wasm)
# Keep hashes separate from names so this remains compatible with Bash 3.2.
asset_hashes=(
  eacd68e8e254bd250bc559c1535ab88df437340d0460cae6085f5f29b49fb6e2
  4e8ee09e67f28a718eb045fb29e676c0ebe467f9f741426f0051d429f5c295f6
  336dcdaf7a3a2337eb2e50b6dc6cc1117681073c25d9f78c8b4eb60e1c5af681
  83dafc125eae5739c67d2a06313cc28748d82730ee1de8098c16b5284ee9ec6d
  19540832f48ae5320a5f08a22023edc574fc7a01f12ee965835a1c31e7f7de71
)

if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
  printf 'Docker and the Docker Compose plugin are required. Run install-docker.sh first.\n' >&2
  exit 1
fi

if [[ ! -f "${compose_source}" ]]; then
  printf 'Compose file not found: %s\n' "${compose_source}" >&2
  exit 1
fi

install -d -m 0755 "${install_dir}" "${install_dir}/site"
install -m 0644 "${compose_source}" "${install_dir}/docker-compose.yml"

for index in "${!asset_names[@]}"; do
  asset="${asset_names[${index}]}"
  curl -fsSL "${asset_base_url}/${asset}" -o "${install_dir}/${asset}.download"
  printf '%s  %s\n' "${asset_hashes[${index}]}" "${install_dir}/${asset}.download" | sha256sum --check --status

  if [[ "${asset}" == 'nginx.conf' ]]; then
    install -m 0644 "${install_dir}/${asset}.download" "${install_dir}/${asset}"
  else
    install -m 0644 "${install_dir}/${asset}.download" "${install_dir}/site/${asset}"
  fi
  rm -f "${install_dir}/${asset}.download"
done

curl -fsSL "${wad_url}" -o "${install_dir}/doom1.wad.download"
printf '%s  %s\n' "${wad_sha256}" "${install_dir}/doom1.wad.download" | sha256sum --check --status
install -m 0644 "${install_dir}/doom1.wad.download" "${install_dir}/site/doom1.wad"
rm -f "${install_dir}/doom1.wad.download"

cd "${install_dir}"
docker compose pull
docker compose up -d --force-recreate

for _ in {1..30}; do
  container_status="$(docker inspect --format '{{.State.Status}}' doom 2>/dev/null || true)"
  [[ "${container_status}" == 'running' ]] && break
  sleep 1
done

container_status="$(docker inspect --format '{{.State.Status}}' doom 2>/dev/null || true)"
if [[ "${container_status:-}" != 'running' ]]; then
  printf 'Doom failed to start. Recent container logs:\n' >&2
  docker logs --tail 50 doom >&2 || true
  exit 1
fi

for _ in {1..30}; do
  if curl -fsS "http://127.0.0.1:8081/" >/dev/null \
    && [[ "$(curl -fsS -o /dev/null -w '%{http_code} %{content_type}' 'http://127.0.0.1:8081/websockets-doom.wasm')" == '200 application/wasm' ]]; then
    break
  fi
  sleep 1
done

if ! curl -fsS "http://127.0.0.1:8081/" | grep -q 'Module.FS_createPreloadedFile' \
  || [[ "$(curl -fsS -o /dev/null -w '%{http_code} %{content_type}' 'http://127.0.0.1:8081/websockets-doom.wasm')" != '200 application/wasm' ]]; then
  printf 'Doom started, but its browser assets failed validation. Recent container logs:\n' >&2
  docker logs --tail 50 doom >&2 || true
  exit 1
fi

raspberry_pi_ip="$(hostname -I | cut -d ' ' -f 1)"
printf 'Doom is available at http://%s:8081\n' "${raspberry_pi_ip:-<raspberry-pi-ip>}"
