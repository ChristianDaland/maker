# Verktøy for Raspberry Pi

Hvilke verktøy vi bruker når vi jobber med Raspberry Pi, og til hva. Installasjonsstatus på PC-en står i [docs/00-oppsett-pc.md](../../docs/00-oppsett-pc.md). Fremgangsmåter står i [docs/01-raspberry-pi.md](../../docs/01-raspberry-pi.md).

## På PC-en

| Verktøy | Brukes til |
|---|---|
| Raspberry Pi Imager (`rpi-imager`) | Skrive Raspberry Pi OS til SD-kort, med hostname, bruker, Wi-Fi og SSH ferdig satt opp |
| SSH (`ssh`, `ssh-keygen`, `ssh-copy-id`) | Logge inn på Pi-en uten passord, med nøkkel |
| VS Code + Remote - SSH | Redigere og kjøre kode direkte på Pi-en fra EliteBooken |
| Git | Koden ligger i `~/maker` på PC-en; `git pull`/`push` eller `rsync` til Pi-en |

## På Pi-en

| Verktøy | Brukes til |
|---|---|
| Raspberry Pi OS Lite (64-bit) | Operativsystem uten skrivebord, for headless bruk |
| `raspi-config` | Slå på kamera, I2C, SPI, seriellport og endre innstillinger |
| Python 3 + `venv` | Ett virtuelt miljø per prosjekt (`.venv/`) |
| `gpiozero` / `lgpio` | Styre GPIO: LED, knapper, motordrivere, servoer |
| `picamera2` | Kameramodulen (installeres med apt, venv med `--system-site-packages`) |
| `smbus2` / `spidev` | Sensorer over I2C og SPI |
| `paho-mqtt` | Sende og ta imot MQTT-meldinger |
| `systemd` | Starte programmer automatisk ved oppstart (én `.service`-fil per program) |
| Docker | Felles tjenester når Pi-en er sentral (se `infrastruktur/`) |
