# Raspberry Pi

## Mine enheter

| Navn (hostname) | Modell | IP / adresse | Rolle | Merknader |
|---|---|---|---|---|
| `pi-sentral` | Raspberry Pi 5 med NVMe-HAT og SSD | `pi-sentral.local` (Wi-Fi) | Sentral: MQTT, Node-RED, InfluxDB, Grafana (Docker) | Under oppsett. Starter fra SSD |
| `pi-test` (forslag) | Raspberry Pi 4, SD-kort | | Testmiljø for pi-sentral (prøve Docker-oppsettet), senere kamera eller lyd | I skuffen |
| `pi-skjerm` (forslag) | Raspberry Pi 3 / 3B+, SD-kort | | Fast Grafana-skjerm i kioskmodus på veggen | I skuffen. `--lett` |
| `pi-sensor-01` (forslag) | Raspberry Pi Zero / Zero 2 W, SD-kort | | Liten, strømgjerrig sensornode (I2C-sensorer → MQTT) | I skuffen. `--lett` |

Rollene merket «forslag» er ikke bestemt. Pi-ene på SD-kort skal ikke ha databaser lokalt – de sender målinger over MQTT til `pi-sentral`.

## Oppsett av pi-sentral

### Handleliste

- [x] **Lagring**: NVMe-HAT med SSD (finnes). Databasene skrives til SSD-en, ikke SD-kort.
- [ ] **For å få OS på SSD-en**, ett av: en USB-adapter for NVMe (da skriver `lag-sd-kort.sh` rett til SSD-en fra PC-en), eller et midlertidig microSD-kort for første oppstart
- [ ] **microSD til Pi 3/4/Zero**: 32 GB, gjerne «High Endurance» (tåler mer skriving)
- [ ] **Strømforsyning**: offisiell Raspberry Pi 27 W USB-C (5 V / 5 A). Vanlige mobilladere gir underspenning og ustabil Pi.
- [ ] **Kjøling**: Raspberry Pi Active Cooler eller kabinett med vifte. Pi 5 struper farten uten kjøling.
- [ ] Kabinett (valgfritt, men beskytter mot kortslutning på skrivebordet)

### Valg (lag-sd-kort.sh gjør dette automatisk)

| Innstilling | Verdi |
|---|---|
| Enhet | Raspberry Pi 5 |
| Operativsystem | Raspberry Pi OS (other) → **Raspberry Pi OS Lite (64-bit)** |
| Hostname | `pi-sentral` |
| Brukernavn | `odd_christian` (samme som på PC-en, så holder det med `ssh pi-sentral`) |
| Passord | Velg et eget passord (trengs for `sudo`) |
| Wi-Fi | Samme nett som PC-en, land `NO` |
| Tid og tastatur | `Europe/Oslo`, `no` |
| SSH | På, **kun offentlig nøkkel**, lim inn innholdet i `~/.ssh/id_ed25519.pub` |

### Starte fra NVMe-SSD

Pi 5 kan starte rett fra SSD-en. To veier:

**A) Med USB-adapter for NVMe på PC-en (enklest):** ta SSD-en ut av HAT-en, sett den i adapteren, og kjør `lag-sd-kort.sh pi-sentral /dev/sdX` mot den. Sett SSD-en tilbake og start. Nyere Pi 5 starter fra NVMe uten endringer i bootloaderen. Gjør den ikke det, bruk vei B én gang.

**B) Med midlertidig SD-kort:** skriv et SD-kort med `lag-sd-kort.sh`, start fra det, og kjør:

```bash
ssh pi-sentral 'bash -s -- --nvme' < ~/maker/verktoy/pi-oppsett.sh
```

`--nvme` oppdaterer bootloaderen, setter oppstartsrekkefølgen til NVMe → SD → USB (`BOOT_ORDER=0xf416`), og slår på PCIe (`dtparam=pciex1`, trengs for HAT-er som ikke er Raspberry Pis egne). Skriv deretter OS-et til SSD-en (f.eks. med `rpi-imager` på Pi-en, eller vei A), ta ut SD-kortet og start på nytt.

Merk:
- `dtparam=pciex1_gen=3` gir mer fart, men er ikke offisielt støttet og virker ikke med alle disker. Ikke slått på.
- SSD-en trekker strøm – den offisielle 27 W-forsyningen er nødvendig.
- Sjekk at Active Cooler ikke kolliderer med HAT-en (de fleste HAT-er som monteres oppå, passer).

### Lette noder på SD-kort (Pi 3, Pi 4, Zero)

SD-kort tåler dårlig mye skriving. For Pi-er som bare sender målinger:

```bash
ssh pi-skjerm 'bash -s -- --lett' < ~/maker/verktoy/pi-oppsett.sh
```

`--lett` legger systemloggen i minnet (`Storage=volatile`) og setter `noatime` på rotpartisjonen. Ingen databaser lokalt.

### Sjekkliste

- [x] SSH-nøkkel på PC-en (`~/.ssh/id_ed25519`)
- [x] `~/.ssh/config` på PC-en med `Host pi-sentral`
- [x] Raspberry Pi OS Lite (trixie, 2026-10-06) lastet ned og kontrollert (`~/.cache/maker/raspios/`)
- [ ] Skaffe utstyr fra handlelisten
- [ ] Skrive SD-kort: `verktoy/lag-sd-kort.sh pi-sentral /dev/mmcblk0`
- [ ] Første oppstart og `ssh pi-sentral`
- [ ] OS på SSD-en (vei A eller B over)
- [ ] `ssh pi-sentral 'bash -s -- --docker --repo' < ~/maker/verktoy/pi-oppsett.sh` og omstart
- [ ] Fast IP-adresse: reserver adressen for Pi-en i ruteren (DHCP-reservasjon), så den alltid får samme IP
- [ ] Koble til med VS Code Remote-SSH
- [ ] Flytte `infrastruktur/` til Pi-en (se [infrastruktur/README.md](../infrastruktur/README.md#flytte-til-pi-sentral))
- [ ] Valgfritt: Tailscale på Pi-en for tilgang utenfra (PC-en har allerede Tailscale)

## Klargjøre et nytt SD-kort (headless)

Headless betyr at Pi-en kjører uten skjerm og tastatur; alt gjøres over nettverket.

### Med skriptet (anbefalt)

[`verktoy/lag-sd-kort.sh`](../verktoy/lag-sd-kort.sh) lager et ferdig kort med én kommando:

```bash
cp ~/maker/verktoy/sd-kort.env.example ~/maker/verktoy/sd-kort.env   # første gang: fyll inn Wi-Fi
~/maker/verktoy/lag-sd-kort.sh --vis-kort                            # finn kortet, f.eks. /dev/mmcblk0
~/maker/verktoy/lag-sd-kort.sh pi-sentral /dev/mmcblk0
```

Skriptet:
1. Laster ned Raspberry Pi OS Lite (64-bit, Debian 13 «trixie», utgaven fra 2026-10-06) til `~/.cache/maker/raspios/` og kontrollerer SHA256. Neste kort bruker den lagrede fila.
2. Nekter å skrive til diskene i maskinen, til partisjoner, og til enheter under 8 GB eller over 512 GB. Ber deg skrive navnet på enheten før noe slettes.
3. Skriver imaget (spør om sudo-passord).
4. Legger cloud-init-oppsett på boot-partisjonen (`user-data`, `network-config`, `meta-data`), med samme innhold som Raspberry Pi Imager 2 lager:
   - hostname, tidssone `Europe/Oslo`, norsk tastatur
   - bruker (standard `odd_christian`) med passord du velger, og sudo uten passord
   - SSH-nøkkelen `~/.ssh/id_ed25519.pub`, SSH på, bare nøkkelinnlogging
   - Wi-Fi fra `verktoy/sd-kort.env` (gitignored), land `NO`, og kablet nett som reserve
   - I2C og SPI på
5. Legger Pi-en inn i `~/.ssh/config` hvis den ikke er der fra før.

Testet 2026-10-25 mot en fil i stedet for et kort: nedlasting, SHA256, utpakking og cloud-init-filene (også Wi-Fi-navn og -passord med spesialtegn og æøå). Ikke testet med ekte kort og Pi ennå.

Ny utgave av Raspberry Pi OS: oppdater `IMAGE_URL` og `IMAGE_SHA256` øverst i skriptet (fra raspberrypi.com/software/operating-systems).

### Med Raspberry Pi Imager

Fra og med Debian 13 «trixie» bruker Raspberry Pi OS **cloud-init** til førstegangsoppsettet. Imager 1.8.5 fra Ubuntu-pakkene er eldre enn denne endringen, og innstillingene den skriver (bruker, Wi-Fi, SSH) blir kanskje ikke brukt. Velger du Imager, bruk versjon 2.x fra [raspberrypi.com/software](https://www.raspberrypi.com/software/), eller skriv kortet med Imager uten innstillinger og kjør `lag-sd-kort.sh` etterpå.

### Første oppstart

```bash
ping pi-sentral.local          # første oppstart tar 2–5 minutter
ssh pi-sentral
```

Fungerer ikke `.local`-navnet, finn IP-adressen i ruterens oversikt over tilkoblede enheter.

## SSH-nøkler

Lag én nøkkel på EliteBooken (bare første gang):

```bash
ls ~/.ssh/id_ed25519.pub || ssh-keygen -t ed25519 -C "elitebook"
```

Har du ikke lagt inn nøkkelen i Imager, kopier den over etterpå:

```bash
ssh-copy-id bruker@pi-sentral.local
```

Legg Pi-en inn i `~/.ssh/config`, så holder det å skrive `ssh pi-sentral`:

```
Host pi-sentral
    HostName pi-sentral.local
    User bruker
    IdentityFile ~/.ssh/id_ed25519
```

## Fjernutvikling med VS Code Remote-SSH

Kode som bruker kamera, GPIO og motorer må kjøre på Pi-en for å nå maskinvaren. Med utvidelsen Remote - SSH kjører VS Code-serveren på Pi-en, mens du redigerer på EliteBooken:

1. Trykk F1 → «Remote-SSH: Connect to Host…» → velg `pi-sentral` (hentes fra `~/.ssh/config`).
2. Åpne en mappe på Pi-en, f.eks. `~/prosjekter/vaerstasjon`.
3. Installer Python-utvidelsen også på Pi-siden når VS Code spør.

Merk: VS Code-serveren trenger litt minne. Pi 3 og nyere går fint; Pi Zero 2 W er i trangeste laget.

## Første ting å gjøre på en ny Pi

Kjør oppsettskriptet fra PC-en (Pi-en må være oppe og nåbar med `ssh`):

```bash
ssh pi-sentral 'bash -s' < ~/maker/verktoy/pi-oppsett.sh                     # grunnoppsett
ssh pi-sentral 'bash -s -- --docker --repo' < ~/maker/verktoy/pi-oppsett.sh  # + Docker og maker-repoet
ssh pi-sentral sudo reboot
```

[`verktoy/pi-oppsett.sh`](../verktoy/pi-oppsett.sh) oppdaterer systemet, installerer git, Python-venv, mosquitto-clients og i2c-tools, slår på I2C og SPI, og legger brukeren i gruppene `gpio`, `i2c`, `spi` og `dialout`. Med `--docker` installeres Docker, og med `--repo` klones dette repoet til `~/maker`. Skriptet er ikke testet på en ekte Pi ennå.

## Ett virtuelt Python-miljø per prosjekt

Nyere Raspberry Pi OS tillater ikke `pip install` direkte i systemets Python. Lag et venv per prosjekt:

```bash
cd ~/prosjekter/vaerstasjon
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Biblioteker som er tett knyttet til maskinvaren (f.eks. `picamera2`, `libcamera`, `lgpio`) installeres best med apt. Da må venv-et få se dem:

```bash
python3 -m venv --system-site-packages .venv
```

## Typiske roller for en Pi i verkstedet

- Sentral for MQTT, Node-RED og dashboards (se [nettverk og sky](03-nettverk-og-sky.md)).
- Kameraenhet med Pi-kameramodul.
- Hjernen i en robot, med motordriver koblet til GPIO.
