#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  printf 'Run this script as root, for example: sudo %s\n' "$0" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates curl gnupg openssl

install -m 0755 -d /etc/apt/keyrings
if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
  curl -fsSL https://download.docker.com/linux/debian/gpg \
    -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
fi

architecture="$(dpkg --print-architecture)"
codename="$(. /etc/os-release && printf '%s' "${VERSION_CODENAME:-bookworm}")"
printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian %s stable\n' \
  "${architecture}" "${codename}" > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

systemctl enable --now docker

if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != 'root' ]]; then
  usermod -aG docker "${SUDO_USER}"
  printf 'Docker is installed. Log out and back in before using Docker without sudo.\n'
else
  printf 'Docker is installed and running.\n'
fi

docker --version
docker compose version
