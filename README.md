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

## Nextcloud

```bash
sudo mkdir -p /opt/raspberry-pi-workshop/nextcloud && cd /opt/raspberry-pi-workshop/nextcloud && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/install-nextcloud.sh -o install-nextcloud.sh && sudo curl -fsSL https://raw.githubusercontent.com/ishrakr/nl-workshop/main/2026-rpi/install-scripts/docker-compose-nextcloud.yml -o docker-compose-nextcloud.yml && sudo bash install-nextcloud.sh
```

Nextcloud will be available at `http://<raspberry-pi-ip>:8080`. The generated administrator credentials are stored in `/opt/raspberry-pi-workshop/nextcloud/.env`.

## Service Commands

Run these commands from the relevant installation directory:

```bash
sudo docker compose ps
sudo docker compose logs -f
sudo docker compose down
sudo docker compose up -d
```

Back up the application data directories and the `.env` file before reinstalling or changing storage.
