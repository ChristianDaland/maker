# Raspberry Pi

## Mine enheter

| Navn (hostname) | Modell | IP / adresse | Rolle | Merknader |
|---|---|---|---|---|
| | | | | |

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
   ssh bruker@pi-sentral.local
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

```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y git python3-venv
```

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
