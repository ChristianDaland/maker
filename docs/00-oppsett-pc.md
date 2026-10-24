# Oppsett av PC-en (HP EliteBook, Linux Mint)

Denne filen beskriver programvaren på EliteBooken som brukes i verkstedet. Kryss av etter hvert som ting er installert, og noter versjon eller spesielle valg under «Kommentarer og endringer».

Maskin: HP EliteBook, Linux Mint 22.3 (Zena, basert på Ubuntu 24.04). Bruker: `odd_christian`.

Sist kontrollert: 2026-10-24.

## Seriellporter og tilgang

Dette må være på plass før ESP32 og andre kort fungerer over USB.

- [ ] **Bruker i gruppen `dialout`** – uten dette får du «Permission denied» på seriellporten.
  ```bash
  sudo usermod -aG dialout $USER
  ```
  Logg deretter ut og inn igjen (eller start på nytt). Sjekk med `groups`.
- [ ] **brltty fjernet** – brltty er et program for leselister (punktskrift). Udev-regelen dens tar tak i CH340-brikker (USB-ID `1a86:7523`), som brukes på mange billige ESP32-kort, og da forsvinner `/dev/ttyUSB0` like etter at kortet kobles til. Bruker du ikke leselist:
  ```bash
  dpkg -s brltty | grep Status      # sjekk om den er installert
  sudo apt remove brltty
  ```
- [ ] **PlatformIO sine udev-regler** – gir riktige rettigheter for en lang rekke kort og programmerere:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules
  sudo udevadm control --reload-rules && sudo udevadm trigger
  ```

### Finne porten

- Kort med CP210x eller CH340 dukker opp som `/dev/ttyUSB0`, `/dev/ttyUSB1` osv.
- Kort med innebygd USB (ESP32-S2/S3/C3, Pico, Arduino Leonardo) dukker gjerne opp som `/dev/ttyACM0`.
- Se hva som skjer når du kobler til et kort:
  ```bash
  sudo dmesg -w          # følg med live, koble til kortet, Ctrl+C for å avslutte
  ls -l /dev/ttyUSB* /dev/ttyACM*
  lsusb                  # viser USB-brikken (f.eks. 10c4:ea60 = CP210x, 1a86:7523 = CH340)
  ```
- Ser du `usbfs: interface 0 claimed by ch341 while 'brltty' sets config` i `dmesg`, er det brltty som stjeler kortet.
- Ingen linjer i `dmesg` i det hele tatt: prøv en annen USB-kabel (mange er kun for lading).

Linux har drivere for CP210x, CH340 og FTDI innebygd, så du trenger ikke installere drivere slik som på Windows.

## Grunnmur

| Verktøy | Brukes til | Installasjon | Installert |
|---|---|---|---|
| Git | Versjonskontroll av all kode og dokumentasjon | `sudo apt install git` | [x] 2.43.0 |
| Python 3 | Skript, dataanalyse, verktøy for ESP32 | Følger med Mint | [x] 3.12.3 |
| python3-venv | Virtuelle miljøer per prosjekt | `sudo apt install python3-venv` | [ ] |
| pipx | Installere Python-verktøy (esptool, platformio) isolert | `sudo apt install pipx && pipx ensurepath` | [ ] |
| VS Code | Hovededitor for alt | Fra Microsofts apt-kilde eller .deb | [x] |
| Docker Engine + Compose | Kjøre MQTT, Node-RED, InfluxDB og Grafana lokalt | Se under | [ ] |
| mosquitto-clients | `mosquitto_pub` / `mosquitto_sub` for å teste MQTT | `sudo apt install mosquitto-clients` | [ ] |

### Docker Engine

Mint 22 bygger på Ubuntu 24.04 «noble». Docker sitt installasjonsskript kjenner ikke Mint, så bruk Dockers apt-kilde med `noble` (se docs.docker.com/engine/install/ubuntu/ og bytt `$VERSION_CODENAME` med `$UBUNTU_CODENAME`). Enkleste alternativ er Ubuntus egne pakker:

```bash
sudo apt install docker.io docker-compose-v2
sudo usermod -aG docker $USER     # logg ut og inn etterpå
```

Merk at gruppen `docker` i praksis gir root-tilgang.

## VS Code-utvidelser

| Utvidelse | ID | Brukes til | Installert |
|---|---|---|---|
| PlatformIO IDE | `platformio.platformio-ide` | Utvikling og flashing av ESP32 og andre mikrokontrollere | [ ] |
| Python | `ms-python.python` | Python-utvikling lokalt og på Pi | [ ] |
| Remote - SSH | `ms-vscode-remote.remote-ssh` | Redigere og kjøre kode direkte på Raspberry Pi | [ ] |
| Markdown All in One | `yzhang.markdown-all-in-one` | Skrive og forhåndsvise dokumentasjonen (valgfri) | [ ] |

Installer fra terminalen med `code --install-extension <ID>`. PlatformIO IDE trenger `python3-venv` for å lage sitt eget miljø i `~/.platformio`.

## Mikrokontrollere

| Verktøy | Brukes til | Installasjon | Installert |
|---|---|---|---|
| esptool | Flashing og diagnose av ESP32 | `pipx install esptool` | [ ] |
| Thonny | MicroPython på ESP32 og Pico | `sudo apt install thonny` (eller `pipx install thonny` for nyeste) | [ ] |
| Arduino IDE 2 | Raske tester og eksempler | AppImage fra arduino.cc, eller Flatpak `cc.arduino.IDE2` | [ ] |

## Raspberry Pi

| Verktøy | Brukes til | Installasjon | Installert |
|---|---|---|---|
| Raspberry Pi Imager | Lage SD-kort med forhåndsinnstilt Wi-Fi, bruker og SSH | `sudo apt install rpi-imager` (eller AppImage fra raspberrypi.com) | [ ] |
| OpenSSH-klient | `ssh`, `ssh-keygen`, `ssh-copy-id` | Følger med Mint | [x] |

## Elektronikk og design

| Verktøy | Brukes til | Installasjon | Installert |
|---|---|---|---|
| KiCad | Koblingsskjema og egne kretskort | `sudo apt install kicad` (eller PPA `kicad/kicad-9.0-releases` for nyeste) | [ ] |
| Fritzing | Enkle koblingsskisser | `sudo apt install fritzing` (eldre versjon, gratis) | [ ] |
| Wokwi (nettleser) | Simulere ESP32/Arduino før du kobler | wokwi.com | – |

## Python-pakker

Installer **aldri** pakker med `pip install` i systemets Python (Mint/Ubuntu stopper det med «externally-managed-environment», og det er bra). I stedet:

- Kommandolinjeverktøy (esptool, platformio, thonny): `pipx install <verktøy>`.
- Biblioteker til et prosjekt: lag et virtuelt miljø i prosjektmappen.

```bash
cd ~/maker/prosjekter/2026-10-noe
python3 -m venv .venv
source .venv/bin/activate
pip install pyserial paho-mqtt opencv-python numpy matplotlib
pip freeze > requirements.txt
```

`.venv/` står i `.gitignore`; `requirements.txt` sjekkes inn.

## Kommentarer og endringer

Skriv her når noe er endret i oppsettet, med dato:

- 2026-10-24: Kartlagt utgangspunkt. Git, Python 3.12 og VS Code finnes. Bruker er ikke i `dialout`. brltty er installert (6.6-4ubuntu5). Resten mangler.
