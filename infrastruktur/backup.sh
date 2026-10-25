#!/usr/bin/env bash
# Tar backup av det som bare ligger i Docker-volumene:
#   - InfluxDB: alle målinger (influx backup)
#   - Node-RED: flyter og krypterte passord (flows.json, flows_cred.json)
#   - Grafana: database med dashbord laget i nettleseren (grafana.db)
#   - Mosquitto: lagrede «retained»-meldinger (mosquitto.db)
#   - .env: passordene (trengs for å lese flows_cred.json og logge inn)
#
#   ./backup.sh                 # backup til ~/maker-backup/ÅÅÅÅ-MM-DD_TTMM
#   BACKUP_MAPPE=/media/usb ./backup.sh
#
# Beholder de 10 nyeste backupene. Backupen inneholder passord – legg den ikke i Git.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
set -a; . ./.env; set +a

mappe="${BACKUP_MAPPE:-$HOME/maker-backup}"
behold="${BEHOLD:-10}"
navn="$(date +%Y-%m-%d_%H%M)"
mal="$mappe/$navn"

dc() { docker compose "$@"; }

mkdir -p "$mal"
chmod 700 "$mappe" "$mal"

echo "==> InfluxDB"
dc exec -T influxdb rm -rf /tmp/backup
dc exec -T influxdb influx backup /tmp/backup -t "$INFLUX_TOKEN" >/dev/null
dc cp influxdb:/tmp/backup "$mal/influxdb" >/dev/null 2>&1
dc exec -T influxdb rm -rf /tmp/backup

echo "==> Node-RED"
mkdir -p "$mal/nodered"
for f in flows.json flows_cred.json package.json; do
    dc cp "nodered:/data/$f" "$mal/nodered/$f" >/dev/null 2>&1 || true
done

echo "==> Grafana"
dc cp grafana:/var/lib/grafana/grafana.db "$mal/grafana.db" >/dev/null 2>&1

echo "==> Mosquitto"
dc cp mosquitto:/mosquitto/data/mosquitto.db "$mal/mosquitto.db" >/dev/null 2>&1 || echo "   (ingen lagrede meldinger ennå)"

echo "==> .env"
cp .env "$mal/env"
chmod 600 "$mal/env"

# Rydd: behold de nyeste
ls -1d "$mappe"/????-??-??_???? 2>/dev/null | sort | head -n -"$behold" | xargs -r rm -rf

echo
echo "Backup: $mal ($(du -sh "$mal" | cut -f1))"
ls -1 "$mal"
