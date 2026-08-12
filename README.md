# Raspberry Pi Workshop

Installation scripts for the 2026 Raspberry Pi workshop. The commands below use the `main` branch of this repository and install applications under `/opt/raspberry-pi-workshop`.

Run each command as one line on a Raspberry Pi running Debian or Raspberry Pi OS 64-bit.

The default Compose files are tuned for low-memory systems. Immich machine learning is disabled by default because it is the largest memory consumer. To enable it, run `sudo IMMICH_ENABLE_ML=1 bash install-immich.sh` from the Immich directory. A 1 GB Pi should use at least 1 GB of swap; 2 GB is recommended when running both applications.

## Docker

```bash
sudo mkdir -p /opt/raspberry-pi-workshop/docker && cd /opt/raspberry-pi-workshop/docker && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/install-docker.sh -o install-docker.sh && sudo bash install-docker.sh
```

Log out and back in after installation so the Docker group membership takes effect.

## Immich

```bash
sudo mkdir -p /opt/raspberry-pi-workshop/immich && cd /opt/raspberry-pi-workshop/immich && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/install-immich.sh -o install-immich.sh && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/docker-compose-immich.yml -o docker-compose-immich.yml && sudo bash install-immich.sh
```

Immich will be available at `http://<raspberry-pi-ip>:2283`. Photos are stored in `/opt/raspberry-pi-workshop/immich/library`.

Immich's machine-learning features are disabled by default to reduce RAM usage. Face recognition, smart search, and similar features will not be available unless the ML profile is enabled.

If Immich is already installed, update its Compose file and restart PostgreSQL:

```bash
cd /opt/raspberry-pi-workshop/immich && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/docker-compose-immich.yml -o docker-compose.yml && sudo docker compose up -d --force-recreate database && sudo docker compose up -d
```

## Nextcloud

```bash
sudo mkdir -p /opt/raspberry-pi-workshop/nextcloud && cd /opt/raspberry-pi-workshop/nextcloud && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/install-nextcloud.sh -o install-nextcloud.sh && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/docker-compose-nextcloud.yml -o docker-compose-nextcloud.yml && sudo bash install-nextcloud.sh
```

Nextcloud will be available at `http://<raspberry-pi-ip>:8080`. The generated administrator credentials are stored in `/opt/raspberry-pi-workshop/nextcloud/.env`.

## Browser GUI

This installs a low-memory noVNC container that shares the Pi's existing X11 desktop in a browser. The Pi must be logged in to its graphical desktop and configured to use X11 rather than Wayland.

```bash
sudo mkdir -p /opt/raspberry-pi-workshop/web-vnc && cd /opt/raspberry-pi-workshop/web-vnc && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/install-web-vnc.sh -o install-web-vnc.sh && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/docker-compose-web-vnc.yml -o docker-compose-web-vnc.yml && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/Dockerfile-web-vnc -o Dockerfile-web-vnc && sudo bash install-web-vnc.sh
```

Open `http://<raspberry-pi-ip>:6080/vnc.html?autoconnect=1&resize=scale`.

This service intentionally has no authentication. Anyone who can reach port `6080` can view and control the Pi. Use it only on a trusted, isolated workshop network and stop it when it is not needed:

```bash
cd /opt/raspberry-pi-workshop/web-vnc && sudo docker compose down
```

## Service Commands

Run these commands from the relevant installation directory:

```bash
sudo docker compose ps
sudo docker compose logs -f
sudo docker compose down
sudo docker compose up -d
```

Back up the application data directories and the `.env` file before reinstalling or changing storage.
