# CLAUDE.md – kontekst for Claude Code i ~/maker

## Hvem og hva

- Hobbyverksted på en HP EliteBook med **Linux Mint 22.3** (Ubuntu 24.04-base), bruker `odd_christian`.
- Prosjekter med Raspberry Pi, ESP32, sensorer, motorer, kamera, roboter, og kombinasjoner av elektronikk, data og skyløsninger.
- **Språk:** brukeren skriver norsk, og all dokumentasjon, alle kommentarer i README-er og commit-meldinger skrives på norsk (bokmål).

## Historikk

Rammeverket ble først laget for Windows (`C:\Maker`, PowerShell, winget, WSL, OneDrive) i en tidligere samtale. Det ble tilpasset Linux Mint 2026-10-24. Ikke foreslå Windows-verktøy, drivere eller stier. `nytt-prosjekt.ps1` er erstattet av `verktoy/nytt-prosjekt.sh`.

## Struktur

| Sti | Innhold |
|---|---|
| `README.md` | Oversikt over verkstedet |
| `docs/00-oppsett-pc.md` | Verktøy på PC-en med **avkrysningslister** – hold dem oppdatert når noe installeres |
| `docs/01-raspberry-pi.md` | rpi-imager, headless, SSH-nøkler, Remote-SSH, venv |
| `docs/02-esp32.md` | PlatformIO, MicroPython, seriellport, BOOT-knapp, secrets |
| `docs/03-nettverk-og-sky.md` | MQTT, Node-RED, InfluxDB, Grafana, Home Assistant, sky |
| `docs/04-elektronikk-og-sikkerhet.md` | Strøm, jord, 3,3 V, motordrivere, batterier |
| `docs/konvensjoner.md` | Navngiving, Git, hemmeligheter |
| `prosjekter/_mal/` | Mal: `README.md` med `{{NAVN}}`/`{{DATO}}`/`{{PLATTFORM}}`, mappene `firmware/`, `pi/`, `hardware/`, `docs/` |
| `prosjekter/<plattform>/` | `raspberry-pi`, `esp32`, `arduino`, `pico`, `pc-og-sky`, `kombinert` (flere plattformer sammen), `reparasjon` |
| `prosjekter/<plattform>/ÅÅÅÅ-MM-<slug>/` | Ett prosjekt per mappe, lages med `verktoy/nytt-prosjekt.sh <plattform> "Navn"` |
| `bibliotek/esp32/`, `bibliotek/python/` | Gjenbrukbar kode |
| `komponenter/lager.md`, `komponenter/datablad/` | Komponentoversikt og datablad |
| `infrastruktur/` | Felles tjenester med Docker Compose (ikke satt opp ennå) |
| `notater/logg.md` | Arbeidslogg, nyeste øverst – **før kort logg etter hver økt** |
| `notater/ideer.md` | Løse ideer |

## Konvensjoner (kort)

- Filnavn og mapper: små bokstaver, bindestrek, ingen æøå. Prosjektmapper `ÅÅÅÅ-MM-navn`.
- Enheter: `esp32-01`, `pi-sentral`, `pi-kamera` – samme navn som hostname og i MQTT.
- MQTT-emner: `maker/<sted>/<enhet>/<måling>`.
- Hemmeligheter i `secrets.*` / `.env` (gitignored), alltid med `secrets.example.*` / `.env.example` ved siden av. Aldri sjekk inn `*.pem`/`*.key`.
- Python: ett `.venv` per prosjekt, aldri `pip install` i systemets Python. CLI-verktøy via `pipx`.

## Linux-spesifikt

- Seriellporter: `/dev/ttyUSB0` (CP210x/CH340) eller `/dev/ttyACM0` (innebygd USB). Feilsøk med `sudo dmesg -w` og `lsusb`.
- Bruker må være i gruppen `dialout`.
- `brltty` stjeler CH340-kort (1a86:7523) – bør fjernes.
- PlatformIO-udev-regler: `/etc/udev/rules.d/99-platformio-udev.rules`.

## Arbeidsmåte for Claude

- **Spør før du installerer noe eller bruker `sudo`.** Vis hva som mangler først.
- Standard filer: hver plattformmappe har `README.md` + `verktoy.md`; hvert prosjekt har `README.md` med «Slik henger det sammen» (deler, dataflyt, kobling). Oppdater `verktoy.md` når et nytt verktøy tas i bruk, og prosjektets README når oppbyggingen endres.
- Oppdater avkrysningslistene i `docs/00-oppsett-pc.md` når noe blir installert (med versjon).
- Før kort logg i `notater/logg.md` etter hver økt.
- Commit med korte norske meldinger. Repoet er **offentlig** på github.com/ChristianDaland/maker (remote `origin`, branch `main`) – sjekk at ingen hemmeligheter eller personlige detaljer er med før push.

## Det som er klart (2026-10-24)

- Alle PC-verktøy installert (se `docs/00-oppsett-pc.md`), inkl. PlatformIO med `espressif32`.
- `infrastruktur/`: Mosquitto, Telegraf, InfluxDB, Grafana og Node-RED kjører i Docker på PC-en. Passord i `infrastruktur/.env` (gitignored). Testet ende til ende.
- `bibliotek/esp32/`: `maker_nett` (Wi-Fi/MQTT) og `cyd` (ESP32-2432S028R «Cheap Yellow Display»).
- `prosjekter/esp32/_firmware-mal/`: ferdig firmware som bygger for `cyd` og `esp32dev`. `nytt-prosjekt.sh esp32` kopierer den og lager `secrets.h`.
- `prosjekter/raspberry-pi/_pi-mal/`: Python-mal (MQTT via `bibliotek/python/maker/mqtt.py`, `.env`). Brukes også av `pc-og-sky/_kode-mal` og `kombinert/` via symlenker. Testet mot infrastrukturen.
- Node-RED krever innlogging (`infrastruktur/nodered/settings.js`), flyten «Verksted» er koblet til Mosquitto.
- PlatformIO-plattformer: `espressif32`, `atmelavr`, `raspberrypi` (offisiell, uten Pico W Wi-Fi). MicroPython for ESP32 i `verktoy/firmware/` (gitignored).
- `verktoy/pi-oppsett.sh`: oppsett av ny Pi over SSH (ikke testet på Pi ennå).
- Wokwi Simulator (VS Code) installert. ESP32-malen har `diagram.json` (CYD-pinner, uten berøring), `wokwi.toml` og `env:wokwi` (Wi-Fi `Wokwi-GUEST`, MQTT `host.wokwi.internal`). Lisensen må brukeren hente selv (30 dager).
- Maskinvare: 4 × CYD bestilt (`esp32-01`–`esp32-04`). Pi 5 (`pi-sentral`), Pi 4, Pi 3, Pi Zero i skuffen. Mangler SD-kort, strøm og kjøling til Pi 5.

## Status og plan

Se `notater/logg.md` for siste status. Plan videre: Raspberry Pi → ESP32 → MQTT/Node-RED-infrastruktur.
