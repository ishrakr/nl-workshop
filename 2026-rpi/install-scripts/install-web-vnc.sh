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

if [[ ! -S /tmp/.X11-unix/X0 ]] || ! xorg_pid="$(pgrep -xo Xorg)"; then
  printf 'No X11 desktop was found on display :0. Log in to the Pi desktop and select X11 with sudo raspi-config (Advanced Options > Wayland > X11).\n' >&2
  exit 1
fi

mapfile -d '' -t xorg_args < "/proc/${xorg_pid}/cmdline" || true
xauthority_file=''
for ((i = 0; i < ${#xorg_args[@]} - 1; i++)); do
  if [[ "${xorg_args[i]}" == '-auth' ]]; then
    xauthority_file="${xorg_args[i + 1]}"
    break
  fi
done

if [[ -z "${xauthority_file}" || ! -f "${xauthority_file}" ]]; then
  for candidate in /run/lightdm/root/:0 /var/run/lightdm/root/:0 /home/*/.Xauthority; do
    if [[ -f "${candidate}" ]]; then
      xauthority_file="${candidate}"
      break
    fi
  done
fi

if [[ -z "${xauthority_file}" || ! -f "${xauthority_file}" ]]; then
  printf 'Could not locate the X11 authorization file for display :0. Ensure a user is logged in to the desktop.\n' >&2
  exit 1
fi

install -d -m 0755 "${install_dir}"
install_dir="$(cd -- "${install_dir}" && pwd)"
cache_buster="$(date +%s)"
curl -fsSL -H 'Cache-Control: no-cache' "${base_url}/docker-compose-web-vnc.yml?${cache_buster}" -o "${install_dir}/docker-compose.yml"
curl -fsSL -H 'Cache-Control: no-cache' "${base_url}/Dockerfile-web-vnc?${cache_buster}" -o "${install_dir}/Dockerfile-web-vnc"
chmod 0644 "${install_dir}/docker-compose.yml" "${install_dir}/Dockerfile-web-vnc"
image_tag="$(date +%s)"
printf 'XAUTHORITY_FILE=%s\nWEB_VNC_IMAGE_TAG=%s\n' "${xauthority_file}" "${image_tag}" > "${install_dir}/.env"

cd "${install_dir}"
docker compose down --remove-orphans
docker compose build --no-cache
docker compose run --rm --no-deps --entrypoint sh web-vnc -c 'command -v xauth >/dev/null'
docker compose up -d --force-recreate

for _ in {1..10}; do
  container_status="$(docker inspect --format '{{.State.Status}}' web_vnc 2>/dev/null || true)"
  [[ "${container_status}" == 'running' ]] && break
  sleep 1
done

sleep 3
container_status="$(docker inspect --format '{{.State.Status}}' web_vnc 2>/dev/null || true)"
if [[ "${container_status:-}" != 'running' ]]; then
  printf 'Web VNC failed to start. Recent container logs:\n' >&2
  docker logs --tail 50 web_vnc >&2 || true
  exit 1
fi

while IFS= read -r old_image; do
  [[ -n "${old_image}" && "${old_image}" != "raspberry-pi-workshop/web-vnc:${image_tag}" ]] || continue
  docker image rm "${old_image}" >/dev/null 2>&1 || true
done < <(docker image ls raspberry-pi-workshop/web-vnc --format '{{.Repository}}:{{.Tag}}')

raspberry_pi_ip="$(hostname -I | cut -d ' ' -f 1)"
printf 'Unauthenticated browser access is available at http://%s:6080/vnc.html?autoconnect=1&resize=scale\n' "${raspberry_pi_ip:-<raspberry-pi-ip>}"
printf 'Using X11 authorization file: %s\n' "${xauthority_file}"
printf 'Anyone who can reach port 6080 can control this Pi. Use only on a trusted workshop network.\n'
