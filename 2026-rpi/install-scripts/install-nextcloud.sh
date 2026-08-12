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

nextcloud_config="${install_dir}/html/config/config.php"
if { [[ -f "${nextcloud_config}" ]] && grep -Eq "['\"]dbtype['\"][[:space:]]*=>[[:space:]]*['\"](mysql|mysqli|pgsql|oci)['\"]" "${nextcloud_config}"; } ||
  { [[ -f "${install_dir}/.env" ]] && grep -q '^MYSQL_' "${install_dir}/.env"; }; then
  backup_dir="${install_dir}-mariadb-backup-$(date +%Y%m%d-%H%M%S)"
  printf 'Existing Nextcloud installation uses an external database and cannot be changed to SQLite automatically.\n' >&2
  printf 'For a fresh SQLite installation, stop it, preserve its files, and rerun the README command:\n' >&2
  printf '  sudo docker compose -f %s/docker-compose.yml down\n' "${install_dir}" >&2
  printf '  cd / && sudo mv %s %s\n' "${install_dir}" "${backup_dir}" >&2
  exit 1
fi

install -d -m 0755 "${install_dir}/html" "${install_dir}/data"
install -m 0644 "${compose_file}" "${install_dir}/docker-compose.yml"

if [[ ! -f "${install_dir}/.env" ]]; then
  read -r raspberry_pi_ip _ < <(hostname -I) || true
  raspberry_pi_ip="${raspberry_pi_ip:-localhost}"
  umask 077
  cat > "${install_dir}/.env" <<EOF
NEXTCLOUD_DIR=${install_dir}
NEXTCLOUD_TRUSTED_DOMAINS=localhost 127.0.0.1 ${raspberry_pi_ip}
EOF
fi

chmod 600 "${install_dir}/.env"
cd "${install_dir}"
docker compose pull
docker compose up -d --remove-orphans

printf 'Nextcloud is running at http://<raspberry-pi-ip>:8080\n'
printf 'Admin username: pi\n'
printf 'Admin password: nlu@2026\n'
