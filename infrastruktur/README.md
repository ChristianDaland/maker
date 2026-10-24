# Infrastruktur

Felles tjenester som flere prosjekter bruker, kjørt med Docker Compose. Samme oppsett kjører på EliteBooken (for testing) og på `pi-sentral` (Raspberry Pi 5) som fast sentral.

Status: **satt opp og testet på EliteBooken 2026-10-24.** Ikke flyttet til `pi-sentral` ennå.

## Slik henger det sammen

```
ESP32-er ──MQTT──► Mosquitto ──► Telegraf ──► InfluxDB ──► Grafana
                       │
                       └──► Node-RED (logikk, varsler, styring)
```

| Tjeneste | Adresse | Rolle |
|---|---|---|
| Mosquitto | `mqtt://<vert>:1883` | MQTT-broker. Krever brukernavn og passord |
| Telegraf | (intern) | Abonnerer på `maker/+/+/+` og skriver alt til InfluxDB |
| InfluxDB 2.7 | http://localhost:8086 | Tidsseriedatabase, bucket `maalinger` |
| Grafana 12.3 | http://localhost:3000 | Dashboards. Datakilde og dashbordet «Verksted – oversikt» lages automatisk |
| Node-RED 4.1 | http://localhost:1880 | Visuelle flyter |

### Fra MQTT til database

Telegraf gjør om emnet til felt i databasen, så nye målinger trenger ikke oppsett:

| MQTT-emne | Melding | Lagres som |
|---|---|---|
| `maker/stue/esp32-01/temperatur` | `21.5` | measurement `temperatur`, tagger `sted=stue`, `enhet=esp32-01`, felt `verdi=21.5` |
| `maker/stue/esp32-01/status` | `online` | measurement `status`, `verdi="online"` (tekst) |

Bare emner med nøyaktig fire nivåer lagres. `maker/stue/esp32-01/kommando/lys` (fem nivåer) går forbi databasen, og passer derfor til kommandoer.

## Filer

| Fil | Innhold |
|---|---|
| `compose.yaml` | Alle tjenestene |
| `.env.example` | Hvilke passord og innstillinger som trengs |
| `.env` | Ekte passord – **gitignored**, lages med `./lag-env.sh` |
| `mosquitto/mosquitto.conf` | Broker: krever innlogging, lagrer meldinger |
| `telegraf/telegraf.conf` | MQTT → InfluxDB |
| `grafana/provisioning/` | Datakilde og dashboard-oppsett som lastes ved oppstart |
| `grafana/dashboards/verksted.json` | Dashbordet «Verksted – oversikt» |

Data lagres i Docker-volumer (`maker_influxdb-data`, `maker_grafana-data` osv.), ikke i repoet.

## Bruk

```bash
cd ~/maker/infrastruktur
./lag-env.sh              # bare første gang
docker compose up -d      # start
docker compose ps         # status
docker compose logs -f    # logger (Ctrl+C for å avslutte)
docker compose down       # stopp – data beholdes
docker compose pull && docker compose up -d   # oppdater til nyeste versjon av hvert image
```

Passordene står i `.env`. Brukernavnet og passordet for MQTT er de samme som ESP32-ene skal ha i `secrets.h`.

Tjenestene starter automatisk når Docker starter (`restart: unless-stopped`). Vil du ikke ha dem kjørende på EliteBooken hele tiden, kjør `docker compose down`.

### Teste fra terminalen

```bash
set -a; . ./.env; set +a
mosquitto_sub -h localhost -u "$MQTT_BRUKER" -P "$MQTT_PASSORD" -t 'maker/#' -v
mosquitto_pub -h localhost -u "$MQTT_BRUKER" -P "$MQTT_PASSORD" -t maker/verksted/test-01/temperatur -m 21.5
```

### Node-RED og MQTT

Første gang i Node-RED: legg til en «mqtt in»-node, og lag en ny broker med server `mosquitto`, port `1883`, og brukernavn og passord fra `.env`.

## Flytte til pi-sentral

1. Sett opp Pi-en med `verktoy/pi-oppsett.sh --docker --repo` (se [docs/01-raspberry-pi.md](../docs/01-raspberry-pi.md)).
2. Kopier `.env` fra PC-en, så ESP32-ene kan bruke de samme passordene:
   `scp ~/maker/infrastruktur/.env pi-sentral:maker/infrastruktur/.env`
3. På Pi-en: `cd ~/maker/infrastruktur && docker compose up -d`
4. Sett `MQTT_VERT` i ESP32-enes `secrets.h` til Pi-ens IP-adresse.
5. Stopp tjenestene på PC-en: `docker compose down`.

Data fra testing på PC-en blir ikke med over (det er bare testdata).

## Sikkerhet

- Portene er åpne mot hjemmenettet, slik at ESP32-ene når broker. Ikke åpne dem mot internett i ruteren. Bruk heller Tailscale for tilgang utenfra.
- Alle tjenestene krever passord. Passordene ligger bare i `.env`.
