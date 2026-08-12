#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  printf 'Run this script as root, for example: sudo %s\n' "$0" >&2
  exit 1
fi

install_dir="${WEB_VNC_DIR:-/opt/raspberry-pi-workshop/web-vnc}"
base_url="https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts"

if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
  printf 'Docker and the Docker Compose plugin are required. Run install-docker.sh first.\n' >&2
  exit 1
fi

if [[ ! -S /tmp/.X11-unix/X0 ]] || ! pgrep -x Xorg >/dev/null 2>&1; then
  printf 'No X11 desktop was found on display :0. Log in to the Pi desktop and select X11 with sudo raspi-config (Advanced Options > Wayland > X11).\n' >&2
  exit 1
fi

install -d -m 0755 "${install_dir}"
install_dir="$(cd -- "${install_dir}" && pwd)"
cache_buster="$(date +%s)"
curl -fsSL -H 'Cache-Control: no-cache' "${base_url}/docker-compose-web-vnc.yml?${cache_buster}" -o "${install_dir}/docker-compose.yml"
curl -fsSL -H 'Cache-Control: no-cache' "${base_url}/Dockerfile-web-vnc?${cache_buster}" -o "${install_dir}/Dockerfile-web-vnc"
chmod 0644 "${install_dir}/docker-compose.yml" "${install_dir}/Dockerfile-web-vnc"

cd "${install_dir}"
docker compose down --remove-orphans
docker image rm raspberry-pi-workshop/web-vnc:latest >/dev/null 2>&1 || true
docker compose build --no-cache
docker compose run --rm --no-deps --entrypoint sh web-vnc -c 'command -v xauth >/dev/null'
docker compose up -d --force-recreate

raspberry_pi_ip="$(hostname -I | cut -d ' ' -f 1)"
printf 'Unauthenticated browser access is available at http://%s:6080/vnc.html?autoconnect=1&resize=scale\n' "${raspberry_pi_ip:-<raspberry-pi-ip>}"
printf 'Anyone who can reach port 6080 can control this Pi. Use only on a trusted workshop network.\n'
