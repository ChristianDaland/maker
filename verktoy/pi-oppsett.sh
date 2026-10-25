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
#   --lett     lett node på SD-kort (Pi 3/4/Zero): logger i minnet, færre skrivinger (noatime)
#   --nvme     Pi 5 med NVMe: oppdater bootloader og start fra NVMe før SD/USB
#
# Forutsetter Raspberry Pi OS (64-bit) satt opp med verktoy/lag-sd-kort.sh (eller Imager),
# der brukeren har sudo uten passord (standard for første bruker).
set -euo pipefail

med_docker=false
med_repo=false
lett=false
nvme=false
for arg in "$@"; do
    case "$arg" in
        --docker) med_docker=true ;;
        --repo)   med_repo=true ;;
        --lett)   lett=true ;;
        --nvme)   nvme=true ;;
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

if $lett; then
    steg "Lett node: mindre skriving til SD-kortet"
    # Systemloggen i minnet (forsvinner ved omstart, men sparer kortet)
    sudo mkdir -p /etc/systemd/journald.conf.d
    printf '[Journal]\nStorage=volatile\nRuntimeMaxUse=30M\n' | sudo tee /etc/systemd/journald.conf.d/90-maker-lett.conf >/dev/null
    sudo systemctl restart systemd-journald
    # noatime: ikke skriv «sist lest»-tid hver gang en fil leses
    if ! grep -qE '\s/\s+\S+\s+\S*noatime' /etc/fstab; then
        sudo sed -i -E '/\s\/\s/ s/(\s(ext4|btrfs)\s+)(\S+)/\1\3,noatime/' /etc/fstab
    fi
    grep -E '\s/\s' /etc/fstab
fi

if $nvme; then
    steg "NVMe-oppstart (Pi 5)"
    grep -q "Raspberry Pi 5" /proc/device-tree/model || { echo "--nvme gjelder bare Pi 5" >&2; exit 1; }
    sudo rpi-eeprom-update -a || true
    # BOOT_ORDER leses bakfra: 6 = NVMe, 1 = SD, 4 = USB, f = prøv igjen
    tmp="$(mktemp)"
    sudo rpi-eeprom-config > "$tmp"
    if grep -q '^BOOT_ORDER=' "$tmp"; then
        sed -i 's/^BOOT_ORDER=.*/BOOT_ORDER=0xf416/' "$tmp"
    else
        echo 'BOOT_ORDER=0xf416' >> "$tmp"
    fi
    # Nødvendig for en del NVMe-adaptere som ikke er Raspberry Pis egne
    grep -q '^PCIE_PROBE=' "$tmp" || echo 'PCIE_PROBE=1' >> "$tmp"
    sudo rpi-eeprom-config --apply "$tmp"
    rm -f "$tmp"
    if ! grep -q '^dtparam=pciex1' /boot/firmware/config.txt; then
        echo 'dtparam=pciex1' | sudo tee -a /boot/firmware/config.txt >/dev/null
    fi
    echo "NVMe-disker funnet:"; lsblk -dno NAME,SIZE,MODEL | grep nvme || echo "  (ingen – sjekk HAT og kabel, start på nytt)"
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
