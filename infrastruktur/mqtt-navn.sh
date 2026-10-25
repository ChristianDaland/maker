#!/usr/bin/env bash
# Annonserer navnet mqtt.local (mDNS/Avahi) med IP-adressen til maskinen som kjører broker.
# Enhetene kobler til «mqtt.local», så når broker flyttes til pi-sentral, flytter navnet med –
# uten at ESP32-ene må flashes på nytt.
#
#   ./mqtt-navn.sh installer   # installer og start som systemd-brukertjeneste (starter ved oppstart)
#   ./mqtt-navn.sh avinstaller
#   ./mqtt-navn.sh status
#   ./mqtt-navn.sh kjor        # kjør i forgrunnen (brukes av tjenesten)
#
# Krever avahi-daemon og avahi-utils (finnes på Linux Mint og Raspberry Pi OS).
set -euo pipefail

NAVN="${MQTT_NAVN:-mqtt.local}"
TJENESTE="maker-mqtt-navn.service"
enhetsfil="$HOME/.config/systemd/user/$TJENESTE"

min_ip() { ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+'; }

case "${1:-}" in
    kjor)
        # Publiser navnet, og start på nytt hvis IP-adressen endrer seg
        while true; do
            ip_na="$(min_ip || true)"
            if [[ -z "$ip_na" ]]; then sleep 10; continue; fi
            echo "Annonserer $NAVN -> $ip_na"
            avahi-publish -a -R "$NAVN" "$ip_na" &
            pid=$!
            while sleep 30; do
                [[ "$(min_ip || true)" == "$ip_na" ]] && kill -0 "$pid" 2>/dev/null || break
            done
            kill "$pid" 2>/dev/null || true
            wait "$pid" 2>/dev/null || true
        done
        ;;
    installer)
        mkdir -p "$(dirname "$enhetsfil")"
        cat > "$enhetsfil" <<EOF
[Unit]
Description=Annonser $NAVN (MQTT-broker for verkstedet) via mDNS
After=network-online.target

[Service]
ExecStart=$(realpath "$0") kjor
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF
        systemctl --user daemon-reload
        systemctl --user enable --now "$TJENESTE"
        # Kjør tjenesten også når ingen er logget inn (viktig på pi-sentral)
        loginctl enable-linger "$USER" 2>/dev/null || echo "Merk: klarte ikke slå på linger (sudo loginctl enable-linger $USER)"
        sleep 2
        "$0" status
        ;;
    avinstaller)
        systemctl --user disable --now "$TJENESTE" 2>/dev/null || true
        rm -f "$enhetsfil"
        systemctl --user daemon-reload
        echo "Fjernet $TJENESTE"
        ;;
    status)
        systemctl --user --no-pager --lines=3 status "$TJENESTE" || true
        echo
        avahi-resolve -4 -n "$NAVN" || echo "$NAVN svarer ikke"
        ;;
    *)
        sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
        exit 1
        ;;
esac
