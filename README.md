# Raspberry Pi Workshop

Easy installers for Raspberry Pi OS.

Run the commands below in a terminal, one at a time.

## 1. Install Docker

```bash
sudo mkdir -p /opt/raspberry-pi-workshop/docker && cd /opt/raspberry-pi-workshop/docker && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/install-docker.sh -o install-docker.sh && sudo bash install-docker.sh
```

Log out and back in when it finishes.

## 2. Choose Apps

### Immich

Photo library.

```bash
sudo mkdir -p /opt/raspberry-pi-workshop/immich && cd /opt/raspberry-pi-workshop/immich && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/install-immich.sh -o install-immich.sh && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/docker-compose-immich.yml -o docker-compose-immich.yml && sudo bash install-immich.sh
```

Open `http://<Pi-IP>:2283`

### Nextcloud

Personal cloud storage.

```bash
sudo mkdir -p /opt/raspberry-pi-workshop/nextcloud && cd /opt/raspberry-pi-workshop/nextcloud && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/install-nextcloud.sh -o install-nextcloud.sh && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/docker-compose-nextcloud.yml -o docker-compose-nextcloud.yml && sudo bash install-nextcloud.sh
```

Open `http://<Pi-IP>:8080`

### RetroAssembly

Play your own retro games in a browser.

```bash
sudo mkdir -p /opt/raspberry-pi-workshop/retroassembly && cd /opt/raspberry-pi-workshop/retroassembly && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/install-retroassembly.sh -o install-retroassembly.sh && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/docker-compose-retroassembly.yml -o docker-compose-retroassembly.yml && sudo bash install-retroassembly.sh
```

Open `http://<Pi-IP>:8000`

### Doom

Play Doom in a browser.

```bash
sudo mkdir -p /opt/raspberry-pi-workshop/doom && cd /opt/raspberry-pi-workshop/doom && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/install-doom.sh -o install-doom.sh && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/docker-compose-doom.yml -o docker-compose-doom.yml && sudo bash install-doom.sh
```

Open `http://<Pi-IP>:8081`

### Browser Desktop

Control the Pi desktop from a browser.

First run `sudo raspi-config`, then choose `Advanced Options > Wayland > X11` and reboot.

```bash
sudo mkdir -p /opt/raspberry-pi-workshop/web-vnc && cd /opt/raspberry-pi-workshop/web-vnc && sudo curl -fsSL -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/install-web-vnc.sh?$(date +%s)" -o install-web-vnc.sh && sudo bash install-web-vnc.sh
```

Open `http://<Pi-IP>:6080/vnc.html?autoconnect=1&resize=scale`

Use Browser Desktop only on a trusted network. It has no password.

## Find Your Pi IP

```bash
hostname -I
```
