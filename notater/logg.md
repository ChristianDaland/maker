# Logg

Kort dagbok over arbeid i verkstedet. Nyeste øverst.

## 2026-10-25
- **Feil rettet:** Mosquitto startet ikke etter omstart (`mosquitto_passwd -c` nekter å overskrive passordfila) – sletter nå fila først. Telegraf ga opp når Mosquitto ikke var oppe – har nå `startup_error_behavior = "retry"`. Testet med full `down`/`up` av stakken. Lærdom: test omstart, ikke bare første oppstart.
- `verktoy/lag-sd-kort.sh`: lager SD-kort med Raspberry Pi OS Lite (trixie) og cloud-init-oppsett. Image lastet ned og SHA256-kontrollert. Testet mot fil. Oppdaget at Imager 1.8.5 er for gammel for trixie sin cloud-init.
- Wokwi Simulator for VS Code installert. ESP32-malen kan simuleres (`env:wokwi`, `diagram.json` med CYD-pinner). Simulert ESP32 når MQTT på PC-en via `host.wokwi.internal`. Berøring kan ikke simuleres.

## 2026-10-24
- Node-RED sikret med innlogging, ferdig koblet til Mosquitto (fanen «Verksted»).
- Python-mal for Pi/PC (`_pi-mal`) og `bibliotek/python/maker/mqtt.py`, testet mot infrastrukturen. `nytt-prosjekt.sh` støtter nå alle `_<mappe>-mal`.
- PlatformIO: lagt til Arduino AVR og Raspberry Pi Pico (testbygg OK). MicroPython 1.29.0 for ESP32 lastet ned. Markdown All in One installert.
- Forberedt alt som kan gjøres uten maskinvare:
  - `infrastruktur/`: Mosquitto + Telegraf + InfluxDB + Grafana + Node-RED i Docker Compose, kjører på PC-en. Testet MQTT → InfluxDB → Grafana. Dashbord «Verksted – oversikt».
  - `bibliotek/esp32/maker_nett` og `bibliotek/esp32/cyd`, firmware-mal for ESP32 (CYD). Testbygget OK.
  - `verktoy/pi-oppsett.sh` for nye Pi-er.
  - ESP32-ene (4 × Cheap Yellow Display, bestilt) og Pi-ene i skuffen ført inn i lageret.
- Raspberry Pi: planlagt `pi-sentral` (Pi 5, Wi-Fi). `~/.ssh/config` laget, handleliste og sjekkliste i `docs/01-raspberry-pi.md`. Venter på SD-kort.
- Installert resten av verktøyene: rpi-imager, Thonny, mosquitto-clients, Docker, KiCad, Fritzing, Arduino IDE (Flatpak), mpremote. Docker + MQTT-rundtur testet OK.
- ESP32-plattformen for PlatformIO lastet ned, testbygg for ESP32, S3 og C3 OK.
- PlatformIO Core 6.2.0 kontrollert og `pio` lagt i PATH. `dialout` aktiv.
- Installert grunnmuren: python3-venv, pipx, esptool 5.6.0, VS Code-utvidelsene PlatformIO/Python/Remote-SSH. Lagt til i `dialout`, fjernet brltty, PlatformIO-udev-regler på plass.
- PS4: demontert, PSU mistenkt defekt, trenger ny kjølepasta. Lagt på is som vinterprosjekt.
- Publisert som offentlig GitHub-repo `ChristianDaland/maker`, med plattformene som mapper og topics for plattformene.
- Ny plattform `reparasjon/` med `verktoy.md`. Prosjekt `reparasjon/2026-10-playstation-4` opprettet; modell og symptom ikke fylt ut ennå.
- Standard filer innført: `verktoy.md` i hver plattformmappe, og prosjektmalens `README.md` har fått delen «Slik henger det sammen» (deler, dataflyt, kobling).
- Prosjekter organisert per plattform: `prosjekter/{raspberry-pi,esp32,arduino,pico,pc-og-sky,kombinert}/`. `nytt-prosjekt.sh` tar nå plattform som første argument.
- Rammeverket fra `Maker.zip` (laget for Windows) tilpasset Linux Mint og lagt i `~/maker`.
- Skrevet om docs for Linux: seriellporter, dialout, brltty, udev, pipx/venv, ssh-copy-id.
- `nytt-prosjekt.ps1` erstattet med `verktoy/nytt-prosjekt.sh`.
- Lagt til `CLAUDE.md`.
- Kartlagt PC-en: git, Python 3.12 og VS Code finnes. Ikke i `dialout`, brltty installert. Resten av verktøyene mangler (se `docs/00-oppsett-pc.md`).
- Git-repo initialisert.
