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
| Node-RED 4.1 | http://localhost:1880 | Visuelle flyter. Krever innlogging. Ferdig koblet til Mosquitto |

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
| `nodered/settings.js` | Node-RED: innlogging og kryptering av lagrede passord |
| `mqtt-navn.sh` | Annonserer `mqtt.local` på hjemmenettet |
| `backup.sh` | Backup av databaser, flyter og `.env` |
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

### Node-RED

- Innlogging: `NODERED_BRUKER` og `NODERED_PASSORD` fra `.env`. Innstillingene ligger i `nodered/settings.js`, og Node-RED nekter å starte uten passord.
- Fanen «Verksted» er ferdig satt opp. Den har en broker-node kalt «Mosquitto» (med MQTT-passordet lagret kryptert) og en flyt som viser alle meldinger under `maker/#` i debug-panelet. Bruk den samme broker-noden i nye flyter.
- `NODERED_KRYPTERINGSNOKKEL` krypterer lagrede passord. Hvis den endres, må passordene i flytene legges inn på nytt.
- Flytene lagres i Docker-volumet `maker_nodered-data`. Eksporter viktige flyter (Meny → Eksporter) og legg dem i prosjektets mappe.

## mqtt.local

`./mqtt-navn.sh installer` lager en systemd-brukertjeneste som annonserer navnet `mqtt.local` (mDNS) med maskinens IP-adresse, og oppdaterer det hvis IP-en endres. ESP32-ene og Python-programmene kobler til `mqtt.local`. Installert og testet på EliteBooken 2026-10-25.

`./mqtt-navn.sh status` viser hva navnet peker på.

## Backup

`./backup.sh` tar backup av det som bare ligger i Docker-volumene: InfluxDB (`influx backup`), Node-RED-flyter, Grafana-databasen, Mosquittos lagrede meldinger og `.env`. Backupen havner i `~/maker-backup/ÅÅÅÅ-MM-DD_TTMM/` (utenfor repoet, kun lesbar for deg), og de 10 nyeste beholdes. Den inneholder passord – ikke legg den i Git.

Gjenopprette InfluxDB:

```bash
docker compose cp ~/maker-backup/<dato>/influxdb influxdb:/tmp/restore
docker compose exec influxdb influx restore /tmp/restore --full -t "$INFLUX_TOKEN"
```

Node-RED: kopier `flows.json` og `flows_cred.json` til `nodered:/data/` og start Node-RED på nytt (krever samme `NODERED_KRYPTERINGSNOKKEL`).

## Flytte til pi-sentral

1. Sett opp Pi-en med `verktoy/pi-oppsett.sh --docker --repo` (se [docs/01-raspberry-pi.md](../docs/01-raspberry-pi.md)).
2. Kopier `.env` fra PC-en, så ESP32-ene kan bruke de samme passordene:
   `scp ~/maker/infrastruktur/.env pi-sentral:maker/infrastruktur/.env`
3. På Pi-en: `cd ~/maker/infrastruktur && docker compose up -d`
4. Flytt navnet: `./mqtt-navn.sh avinstaller` på PC-en, og `./mqtt-navn.sh installer` på Pi-en. ESP32-ene finner den nye brokeren av seg selv.
5. Stopp tjenestene på PC-en: `docker compose down`.

Data fra testing på PC-en blir ikke med over (det er bare testdata).

## Sikkerhet

- Portene er åpne mot hjemmenettet, slik at ESP32-ene når broker. Ikke åpne dem mot internett i ruteren. Bruk heller Tailscale for tilgang utenfra.
- Alle tjenestene krever passord. Passordene ligger bare i `.env`.
