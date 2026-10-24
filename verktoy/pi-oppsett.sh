#!/usr/bin/env bash
# Gjør en nyinstallert Raspberry Pi klar for verkstedet.
# Kjøres PÅ Pi-en, men startes enklest fra PC-en:
#
#   ssh pi-sentral 'bash -s' < ~/maker/verktoy/pi-oppsett.sh              # grunnoppsett
#   ssh pi-sentral 'bash -s -- --docker' < ~/maker/verktoy/pi-oppsett.sh  # + Docker
#
# Valg:
#   --docker   installer Docker Engine + Compose (for pi-sentral og andre som skal kjøre tjenester)
#   --repo     klon github.com/ChristianDaland/maker til ~/maker (f.eks. for infrastruktur/)
#
# Forutsetter Raspberry Pi OS (64-bit) satt opp med Raspberry Pi Imager,
# der brukeren har sudo uten passord (standard for første bruker).
set -euo pipefail

med_docker=false
med_repo=false
for arg in "$@"; do
    case "$arg" in
        --docker) med_docker=true ;;
        --repo)   med_repo=true ;;
        *) echo "Ukjent valg: $arg" >&2; exit 1 ;;
    esac
done

steg() { printf '\n==> %s\n' "$*"; }

if ! grep -qi "raspberry pi" /proc/device-tree/model 2>/dev/null; then
    echo "Dette ser ikke ut som en Raspberry Pi – avbryter." >&2
    exit 1
fi
echo "Maskin: $(tr -d '\0' < /proc/device-tree/model), $(. /etc/os-release && echo "$PRETTY_NAME")"

steg "Oppdaterer systemet"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y

steg "Installerer grunnpakker"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git python3-venv python3-pip python3-dev \
    mosquitto-clients i2c-tools \
    htop vim curl

steg "Slår på I2C og SPI"
sudo raspi-config nonint do_i2c 0
sudo raspi-config nonint do_spi 0

steg "Legger brukeren i gpio, i2c, spi og dialout"
for g in gpio i2c spi dialout; do
    getent group "$g" >/dev/null && sudo usermod -aG "$g" "$USER"
done

if $med_docker; then
    steg "Installerer Docker"
    if command -v docker >/dev/null; then
        echo "Docker finnes allerede: $(docker --version)"
    else
        # Dockers offisielle skript støtter Raspberry Pi OS (Debian, 64-bit)
        curl -fsSL https://get.docker.com | sudo sh
    fi
    sudo usermod -aG docker "$USER"
    sudo systemctl enable --now docker
fi

if $med_repo; then
    steg "Henter maker-repoet"
    if [[ -d "$HOME/maker/.git" ]]; then
        git -C "$HOME/maker" pull --ff-only
    else
        git clone https://github.com/ChristianDaland/maker.git "$HOME/maker"
    fi
fi

steg "Ferdig"
echo "Start Pi-en på nytt for at gruppene og eventuelle kjerneoppdateringer skal tre i kraft:"
echo "  sudo reboot"
