#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  printf 'Run this script as root, for example: sudo %s\n' "$0" >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
install_dir="${NEXTCLOUD_DIR:-/opt/raspberry-pi-workshop/nextcloud}"
compose_file="${script_dir}/docker-compose-nextcloud.yml"
compose_url="${NEXTCLOUD_COMPOSE_URL:-https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/docker-compose-nextcloud.yml}"

if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
  printf 'Docker and the Docker Compose plugin are required. Run install-docker.sh first.\n' >&2
  exit 1
fi

if [[ ! -f "${compose_file}" ]]; then
  curl -fsSL "${compose_url}" -o "${compose_file}"
fi

install -d -m 0755 "${install_dir}/html" "${install_dir}/data" "${install_dir}/db" "${install_dir}/redis"
install -m 0644 "${compose_file}" "${install_dir}/docker-compose.yml"

if [[ ! -f "${install_dir}/.env" ]]; then
  db_password="$(openssl rand -hex 24)"
  root_password="$(openssl rand -hex 24)"
  admin_password="$(openssl rand -hex 12)"
  read -r raspberry_pi_ip _ < <(hostname -I) || true
  raspberry_pi_ip="${raspberry_pi_ip:-localhost}"
  umask 077
  cat > "${install_dir}/.env" <<EOF
NEXTCLOUD_DIR=${install_dir}
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud
MYSQL_PASSWORD=${db_password}
MYSQL_ROOT_PASSWORD=${root_password}
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=${admin_password}
NEXTCLOUD_TRUSTED_DOMAINS=localhost 127.0.0.1 ${raspberry_pi_ip}
EOF
fi

chmod 600 "${install_dir}/.env"
cd "${install_dir}"
docker compose pull
docker compose up -d

printf 'Nextcloud is running at http://<raspberry-pi-ip>:8080\n'
printf 'Admin username and generated password: %s/.env\n' "${install_dir}"
