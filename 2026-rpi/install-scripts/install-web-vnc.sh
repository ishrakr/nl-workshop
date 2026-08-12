#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  printf 'Run this script as root, for example: sudo %s\n' "$0" >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
install_dir="${WEB_VNC_DIR:-/opt/raspberry-pi-workshop/web-vnc}"
base_url="https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts"
compose_file="${script_dir}/docker-compose-web-vnc.yml"
dockerfile="${script_dir}/Dockerfile-web-vnc"

if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
  printf 'Docker and the Docker Compose plugin are required. Run install-docker.sh first.\n' >&2
  exit 1
fi

if [[ ! -S /tmp/.X11-unix/X0 ]]; then
  printf 'No X11 desktop was found on display :0. Log in to the Pi desktop and ensure Raspberry Pi OS uses X11 rather than Wayland.\n' >&2
  exit 1
fi

install -d -m 0755 "${install_dir}"
if [[ ! -f "${compose_file}" ]]; then
  curl -fsSL "${base_url}/docker-compose-web-vnc.yml" -o "${compose_file}"
fi
if [[ ! -f "${dockerfile}" ]]; then
  curl -fsSL "${base_url}/Dockerfile-web-vnc" -o "${dockerfile}"
fi
install -m 0644 "${compose_file}" "${install_dir}/docker-compose.yml"
install -m 0644 "${dockerfile}" "${install_dir}/Dockerfile-web-vnc"

cd "${install_dir}"
docker compose up -d --build

raspberry_pi_ip="$(hostname -I | cut -d ' ' -f 1)"
printf 'Unauthenticated browser access is available at http://%s:6080/vnc.html?autoconnect=1&resize=scale\n' "${raspberry_pi_ip:-<raspberry-pi-ip>}"
printf 'Anyone who can reach port 6080 can control this Pi. Use only on a trusted workshop network.\n'
