#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  printf 'Run this script as root, for example: sudo %s\n' "$0" >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
install_dir="${IMMICH_DIR:-/opt/raspberry-pi-workshop/immich}"
compose_file="${script_dir}/docker-compose-immich.yml"
compose_url="${IMMICH_COMPOSE_URL:-https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/docker-compose-immich.yml}"

if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
  printf 'Docker and the Docker Compose plugin are required. Run install-docker.sh first.\n' >&2
  exit 1
fi

if [[ ! -f "${compose_file}" ]]; then
  curl -fsSL "${compose_url}" -o "${compose_file}"
fi

install -d -m 0755 "${install_dir}/library" "${install_dir}/postgres" "${install_dir}/model-cache"
install -m 0644 "${compose_file}" "${install_dir}/docker-compose.yml"

if [[ ! -f "${install_dir}/.env" ]]; then
  database_password="$(openssl rand -hex 24)"
  umask 077
  cat > "${install_dir}/.env" <<EOF
UPLOAD_LOCATION=${install_dir}/library
DB_DATA_LOCATION=${install_dir}/postgres
MODEL_CACHE_LOCATION=${install_dir}/model-cache
DB_PASSWORD=${database_password}
DB_USERNAME=immich
DB_DATABASE_NAME=immich
DB_HOSTNAME=database
IMMICH_VERSION=release
EOF
fi

chmod 600 "${install_dir}/.env"
cd "${install_dir}"
compose_args=()
if [[ "${IMMICH_ENABLE_ML:-0}" == '1' ]]; then
  compose_args+=(--profile ml)
  printf 'Immich machine learning is enabled and may require additional RAM.\n'
fi
docker compose "${compose_args[@]}" pull
docker compose "${compose_args[@]}" up -d

printf 'Immich is running at http://<raspberry-pi-ip>:2283\n'
printf 'Configuration: %s/.env\n' "${install_dir}"
