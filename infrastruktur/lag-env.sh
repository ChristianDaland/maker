#!/usr/bin/env bash
# Lager .env fra .env.example med tilfeldige passord og token.
# Rører ikke en .env som finnes fra før.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if [[ -e .env ]]; then
    echo ".env finnes allerede – lar den være." >&2
    exit 1
fi

tilfeldig() { head -c 48 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c "$1"; }

sed -e "s|^MQTT_PASSORD=$|MQTT_PASSORD=$(tilfeldig 24)|" \
    -e "s|^INFLUX_PASSORD=$|INFLUX_PASSORD=$(tilfeldig 24)|" \
    -e "s|^INFLUX_TOKEN=$|INFLUX_TOKEN=$(tilfeldig 48)|" \
    -e "s|^GRAFANA_PASSORD=$|GRAFANA_PASSORD=$(tilfeldig 24)|" \
    -e "s|^NODERED_PASSORD=$|NODERED_PASSORD=$(tilfeldig 24)|" \
    -e "s|^OTA_PASSORD=$|OTA_PASSORD=$(tilfeldig 24)|" \
    -e "s|^NODERED_KRYPTERINGSNOKKEL=$|NODERED_KRYPTERINGSNOKKEL=$(tilfeldig 48)|" \
    .env.example > .env
chmod 600 .env

echo "Laget .env med tilfeldige passord. Se passordene med: cat $(pwd)/.env"
