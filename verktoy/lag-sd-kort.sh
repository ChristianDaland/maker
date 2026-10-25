#!/usr/bin/env bash
# Lager et ferdig SD-kort (eller NVMe-SSD i USB-adapter) med Raspberry Pi OS Lite (64-bit)
# for en Pi i verkstedet.
#
#   verktoy/lag-sd-kort.sh <hostname> <enhet>         # skriv til SD-kort, f.eks. /dev/mmcblk0
#   verktoy/lag-sd-kort.sh <hostname> --fil <bilde>   # skriv til en fil (for testing)
#   verktoy/lag-sd-kort.sh --vis-kort                 # vis aktuelle kort/minnepinner
#
# Kortet får (via cloud-init, samme oppsett som Raspberry Pi Imager 2 lager):
#   - hostname, tidssone Europe/Oslo, norsk tastatur
#   - bruker med passord, SSH-nøkkelen fra ~/.ssh/id_ed25519.pub, sudo uten passord
#   - SSH på, kun nøkkelinnlogging
#   - Wi-Fi fra verktoy/sd-kort.env (spør hvis det mangler)
#   - I2C og SPI på
#
# Etter første oppstart: ssh <hostname>, og kjør verktoy/pi-oppsett.sh.
set -euo pipefail

# Raspberry Pi OS Lite (64-bit), Debian 13 «trixie». Oppdater ved ny utgave:
# https://www.raspberrypi.com/software/operating-systems/
IMAGE_URL="https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2026-10-06/2026-10-06-raspios-trixie-arm64-lite.img.xz"
IMAGE_SHA256="483db18a48da399b5b7022ffae9a07bc6d99daab30e593aedac09b69ff422843"

rot="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/maker/raspios"
nokkel="$HOME/.ssh/id_ed25519.pub"

feil() { echo "Feil: $*" >&2; exit 1; }
steg() { printf '\n==> %s\n' "$*"; }

vis_kort() {
    echo "Flyttbare disker / kortlesere (systemdiskene er ikke med):"
    lsblk -dpno NAME,SIZE,TRAN,RM,MODEL | awk '$3!="sata" && $3!="nvme" && $1!~/loop|zram|sr/'
}

if [[ "${1:-}" == "--vis-kort" ]]; then vis_kort; exit 0; fi

[[ $# -ge 2 ]] || { sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

hostname="$1"
[[ "$hostname" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]] || feil "ugyldig hostname «$hostname» (små bokstaver, tall og bindestrek)"

til_fil=false
if [[ "$2" == "--fil" ]]; then
    [[ $# -eq 3 ]] || feil "mangler filnavn etter --fil"
    mal="$3"; til_fil=true; SUDO=""
else
    mal="$2"; SUDO="sudo"
fi

[[ -r "$nokkel" ]] || feil "fant ikke SSH-nøkkelen $nokkel"

# --- Innstillinger ---------------------------------------------------------
if [[ -r "$rot/verktoy/sd-kort.env" ]]; then
    # shellcheck disable=SC1091
    . "$rot/verktoy/sd-kort.env"
fi
WIFI_LAND="${WIFI_LAND:-NO}"
PI_BRUKER="${PI_BRUKER:-$USER}"
if [[ -z "${WIFI_SSID:-}" ]]; then read -rp "Wi-Fi-navn (SSID): " WIFI_SSID; fi
if [[ -z "${WIFI_PASSORD:-}" ]]; then read -rsp "Wi-Fi-passord: " WIFI_PASSORD; echo; fi
[[ -n "$WIFI_SSID" ]] || feil "Wi-Fi-navn mangler"

if [[ -z "${PI_PASSORD_HASH:-}" ]]; then
    read -rsp "Passord for $PI_BRUKER på $hostname (brukes til konsoll og sudo-prompt): " pw1; echo
    read -rsp "Gjenta passordet: " pw2; echo
    [[ -n "$pw1" && "$pw1" == "$pw2" ]] || feil "passordene er tomme eller ulike"
    PI_PASSORD_HASH="$(printf '%s' "$pw1" | openssl passwd -6 -stdin)"
    unset pw1 pw2
fi

# --- Sjekk målet før vi gjør noe -------------------------------------------
if ! $til_fil; then
    [[ -b "$mal" ]] || feil "$mal er ikke en blokkenhet. Bruk --vis-kort for å se kortene."
    [[ "$(lsblk -dno TYPE "$mal")" == "disk" ]] || feil "$mal er en partisjon – oppgi hele kortet (f.eks. /dev/mmcblk0 eller /dev/sdc)"
    tran="$(lsblk -dno TRAN "$mal" | tr -d ' ')"
    [[ "$tran" != "sata" && "$tran" != "nvme" ]] || feil "$mal er en $tran-disk i maskinen – nekter å skrive til den"
    if lsblk -nro MOUNTPOINTS "$mal" | grep -qE '^/$|^/boot|^/home|^/mnt/data'; then
        feil "$mal har systempartisjoner montert – nekter å skrive til den"
    fi
    storrelse=$(lsblk -bdno SIZE "$mal")
    (( storrelse <= 4096 * 1024**3 )) || feil "$mal er større enn 4 TB – ser ikke ut som et SD-kort eller en Pi-SSD"
    (( storrelse >= 8 * 1024**3 )) || feil "$mal er mindre enn 8 GB – for lite"

    echo
    lsblk -po NAME,SIZE,TRAN,MODEL,MOUNTPOINTS "$mal"
    echo
    echo "ALT på $mal blir slettet og erstattet med Raspberry Pi OS for «$hostname»."
    read -rp "Skriv navnet på enheten ($mal) for å fortsette: " svar
    [[ "$svar" == "$mal" ]] || feil "avbrutt"
fi

# --- Hent og kontroller image ----------------------------------------------
mkdir -p "$cache"
image="$cache/$(basename "$IMAGE_URL")"
if [[ ! -f "$image" ]] || ! echo "$IMAGE_SHA256  $image" | sha256sum -c --quiet 2>/dev/null; then
    steg "Laster ned $(basename "$image")"
    curl -fL --progress-bar -o "$image.part" "$IMAGE_URL"
    mv "$image.part" "$image"
fi
steg "Kontrollerer SHA256"
echo "$IMAGE_SHA256  $image" | sha256sum -c --quiet || feil "kontrollsummen stemmer ikke – slett $image og prøv igjen"
echo "OK"

# --- Skriv image -----------------------------------------------------------
if $til_fil; then
    steg "Pakker ut til $mal"
    xz -dc "$image" > "$mal"
else
    steg "Avmonterer partisjoner på $mal"
    while read -r part mp; do
        [[ -n "$mp" ]] && udisksctl unmount -b "$part" >/dev/null
    done < <(lsblk -lnpo NAME,MOUNTPOINT "$mal" | tail -n +2)
    steg "Skriver til $mal (tar noen minutter)"
    xz -dc "$image" | sudo dd of="$mal" bs=4M conv=fsync status=progress
    sudo partprobe "$mal" || true
fi

# --- Lag cloud-init-filer --------------------------------------------------
yaml() { local s="${1//\\/\\\\}"; printf '%s' "${s//\"/\\\"}"; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/meta-data" <<EOF
instance-id: maker-$hostname-$(date +%Y%m%d%H%M%S)
EOF

cat > "$tmp/user-data" <<EOF
#cloud-config
# Laget av ~/maker/verktoy/lag-sd-kort.sh $(date +%Y-%m-%d)
hostname: "$(yaml "$hostname")"
manage_etc_hosts: true
packages:
- avahi-daemon
apt:
  preserve_sources_list: true
  conf: |
    Acquire {
      Check-Date "false";
    };
timezone: "Europe/Oslo"
keyboard:
  model: pc105
  layout: "no"
user:
  name: "$(yaml "$PI_BRUKER")"
  shell: /bin/bash
  lock_passwd: false
  passwd: "$(yaml "$PI_PASSORD_HASH")"
  ssh_authorized_keys:
    - "$(yaml "$(head -n1 "$nokkel" | sed 's/[[:space:]]*$//')")"
  sudo: ALL=(ALL) NOPASSWD:ALL
ssh_pwauth: false
rpi:
  interfaces:
    i2c: true
    spi: true
runcmd:
  - [ systemctl, enable, --now, ssh ]
  - [ sh, -c, "echo '$PI_BRUKER ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/010_$PI_BRUKER-nopasswd" ]
  - [ chmod, "0440", "/etc/sudoers.d/010_$PI_BRUKER-nopasswd" ]
EOF

cat > "$tmp/network-config" <<EOF
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      dhcp6: true
      optional: true
  wifis:
    wlan0:
      dhcp4: true
      regulatory-domain: "$(yaml "$WIFI_LAND")"
      access-points:
        "$(yaml "$WIFI_SSID")":
          password: "$(yaml "$WIFI_PASSORD")"
      optional: true
EOF

python3 -c 'import sys, yaml; [yaml.safe_load(open(f)) for f in sys.argv[1:]]' \
    "$tmp/user-data" "$tmp/network-config" "$tmp/meta-data" || feil "cloud-init-filene er ikke gyldig YAML"

# --- Legg filene på boot-partisjonen (FAT) ---------------------------------
steg "Skriver oppsett til boot-partisjonen"
start=$($SUDO sfdisk -J "$mal" | python3 -c 'import json,sys; print(json.load(sys.stdin)["partitiontable"]["partitions"][0]["start"])')
export MTOOLS_SKIP_CHECK=1
for f in user-data network-config meta-data; do
    $SUDO env MTOOLS_SKIP_CHECK=1 mcopy -o -i "$mal@@$((start * 512))" "$tmp/$f" "::$f"
done
echo "Filer på boot-partisjonen:"
$SUDO env MTOOLS_SKIP_CHECK=1 mdir -b -i "$mal@@$((start * 512))" :: | grep -E 'user-data|network-config|meta-data|config.txt'

if ! $til_fil; then
    sync
    udisksctl power-off -b "$mal" >/dev/null 2>&1 || true

    # Legg Pi-en inn i ~/.ssh/config, så holder det med «ssh <hostname>»
    if ! grep -qE "^Host $hostname\$" "$HOME/.ssh/config" 2>/dev/null; then
        printf '\nHost %s\n    HostName %s.local\n    User %s\n    IdentityFile ~/.ssh/id_ed25519\n' \
            "$hostname" "$hostname" "$PI_BRUKER" >> "$HOME/.ssh/config"
        chmod 600 "$HOME/.ssh/config"
        echo "La til «Host $hostname» i ~/.ssh/config"
    fi
fi

steg "Ferdig"
cat <<EOF
Kortet er klart for «$hostname». Neste steg:
  1. Sett kortet i Pi-en og koble til strøm. Første oppstart tar 2–5 minutter.
  2. ping $hostname.local
  3. ssh $hostname        (legg inn Host $hostname i ~/.ssh/config hvis den mangler)
  4. ssh $hostname 'bash -s' < $rot/verktoy/pi-oppsett.sh
EOF
