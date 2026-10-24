# Raspberry Pi

## Mine enheter

| Navn (hostname) | Modell | IP / adresse | Rolle | Merknader |
|---|---|---|---|---|
| `pi-sentral` | Raspberry Pi 5 | `pi-sentral.local` (Wi-Fi) | Sentral: MQTT, Node-RED, InfluxDB, Grafana (Docker) | Under oppsett – venter på SD-kort |
| – | Raspberry Pi 4 | | Ikke bestemt | I skuffen. Kandidat: `pi-kamera` eller `pi-robot` |
| – | Raspberry Pi 3 / 3B+ | | Ikke bestemt | I skuffen |
| – | Raspberry Pi Zero / Zero 2 W | | Ikke bestemt | I skuffen. Lite minne – best til enkle oppgaver |

## Oppsett av pi-sentral

### Handleliste

- [ ] **microSD-kort**, 32–64 GB, klasse A2 (f.eks. SanDisk Extreme eller Samsung PRO Endurance – sistnevnte tåler mye skriving, som passer en database)
- [ ] **Strømforsyning**: offisiell Raspberry Pi 27 W USB-C (5 V / 5 A). Vanlige mobilladere gir underspenning og ustabil Pi.
- [ ] **Kjøling**: Raspberry Pi Active Cooler eller kabinett med vifte. Pi 5 struper farten uten kjøling.
- [ ] Kabinett (valgfritt, men beskytter mot kortslutning på skrivebordet)
- [ ] Senere, valgfritt: M.2 HAT+ med NVMe-SSD – raskere og mer holdbart enn SD-kort for databaser

### Valg i Raspberry Pi Imager

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

### Sjekkliste

- [x] SSH-nøkkel på PC-en (`~/.ssh/id_ed25519`)
- [x] `~/.ssh/config` på PC-en med `Host pi-sentral`
- [ ] Skaffe utstyr fra handlelisten
- [ ] Skrive SD-kort med valgene over
- [ ] Første oppstart og `ssh pi-sentral`
- [ ] `ssh pi-sentral 'bash -s -- --docker --repo' < ~/maker/verktoy/pi-oppsett.sh` og omstart
- [ ] Fast IP-adresse: reserver adressen for Pi-en i ruteren (DHCP-reservasjon), så den alltid får samme IP
- [ ] Koble til med VS Code Remote-SSH
- [ ] Flytte `infrastruktur/` til Pi-en (se [infrastruktur/README.md](../infrastruktur/README.md#flytte-til-pi-sentral))
- [ ] Valgfritt: Tailscale på Pi-en for tilgang utenfra (PC-en har allerede Tailscale)

## Klargjøre et nytt SD-kort (headless)

Headless betyr at Pi-en kjører uten skjerm og tastatur; alt gjøres over nettverket.

1. Start Raspberry Pi Imager (`rpi-imager`) og velg modell, operativsystem (Raspberry Pi OS Lite, 64-bit, for headless bruk) og SD-kortet.
2. Velg «Rediger innstillinger» før skriving og sett:
   - hostname, f.eks. `pi-sentral` (se [konvensjoner](konvensjoner.md))
   - brukernavn og passord
   - Wi-Fi-navn, passord og land (NO)
   - tidssone `Europe/Oslo` og tastatur `no`
   - under «Tjenester»: aktiver SSH og velg «Tillat kun autentisering med offentlig nøkkel», og lim inn innholdet i `~/.ssh/id_ed25519.pub` (se under)
3. Skriv kortet, sett det i Pi-en og start den. Etter et par minutter:
   ```bash
   ping pi-sentral.local
   ssh bruker@pi-sentral.local     # eller bare: ssh pi-sentral, med oppsettet i ~/.ssh/config
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
