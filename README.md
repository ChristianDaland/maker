# Maker – hobbyverksted på EliteBook

Dette er det faste området på maskinen for alle hobbyprosjekter med Raspberry Pi, ESP32, sensorer, motorer, kamera, roboter og kombinasjoner av elektronikk, data og sky.

Alt som har med disse prosjektene å gjøre, bor her: kode, koblingsskjemaer, notater, datablad og oppsett av tjenester. Målet er at det skal være lett å finne igjen ting, lett å starte nye prosjekter, og lett å gjenbruke det som allerede fungerer.

## Plassering

Rotmappen er `~/maker` (`/home/odd_christian/maker`) på en HP EliteBook med Linux Mint. Stien er kort og har verken mellomrom eller æ, ø, å, noe som unngår trøbbel med PlatformIO og andre byggeverktøy.

Sikkerhetskopi og deling håndteres med Git og GitHub: [github.com/ChristianDaland/maker](https://github.com/ChristianDaland/maker) (offentlig). Plattformene er mapper i repoet, akkurat som lokalt.

## Mappestruktur

| Mappe | Innhold |
|---|---|
| `docs/` | Dokumentasjon av selve oppsettet: verktøy, rutiner og konvensjoner |
| `prosjekter/` | Prosjekter sortert per plattform (se under), laget fra malen i `prosjekter/_mal/` |
| `bibliotek/` | Gjenbrukbar kode som deles mellom prosjekter (ESP32 og Python) |
| `komponenter/` | Oversikt over komponenter du har (`lager.md`) og datablad |
| `infrastruktur/` | Felles tjenester: MQTT-broker, Node-RED, database, dashboards |
| `verktoy/` | Hjelpeskript, f.eks. for å opprette nye prosjekter |
| `notater/` | Løse notater, ideer og en logg over hva som er gjort |

## Prosjekter per plattform

| Plattform | Hva som ligger der | Verktøy |
|---|---|---|
| [raspberry-pi](prosjekter/raspberry-pi/) | Kjører på en Raspberry Pi | [verktoy.md](prosjekter/raspberry-pi/verktoy.md) |
| [esp32](prosjekter/esp32/) | ESP32 som hovedenhet | [verktoy.md](prosjekter/esp32/verktoy.md) |
| [arduino](prosjekter/arduino/) | Arduino Uno, Nano, Mega osv. | [verktoy.md](prosjekter/arduino/verktoy.md) |
| [pico](prosjekter/pico/) | Raspberry Pi Pico (RP2040/RP2350) | [verktoy.md](prosjekter/pico/verktoy.md) |
| [pc-og-sky](prosjekter/pc-og-sky/) | Kjører på PC-en eller i skyen, uten mikrokontroller | [verktoy.md](prosjekter/pc-og-sky/verktoy.md) |
| [kombinert](prosjekter/kombinert/) | Flere plattformer sammen, f.eks. ESP32-sensorer + Pi-sentral | [verktoy.md](prosjekter/kombinert/verktoy.md) |
| [reparasjon](prosjekter/reparasjon/) | Reparere ferdige produkter, f.eks. spillkonsoller | [verktoy.md](prosjekter/reparasjon/verktoy.md) |

Malen for nye prosjekter ligger i [prosjekter/_mal/](prosjekter/_mal/).

Hver plattformmappe har en `README.md` (hva som hører hjemme der) og en `verktoy.md` (hvilke verktøy vi bruker). Under hver plattform ligger én mappe per prosjekt, f.eks. `prosjekter/esp32/2026-10-vaerstasjon-ute/`, og hvert prosjekt har en `README.md` som forklarer prosjektet og hvordan det henger sammen.

Trengs en ny plattform, lag en ny mappe i `prosjekter/` med `README.md` og `verktoy.md`, så kjenner skriptet den igjen automatisk.

## Dokumentasjon

1. [Oppsett av PC-en](docs/00-oppsett-pc.md) – programmer, seriellporter og avkrysningslister
2. [Raspberry Pi](docs/01-raspberry-pi.md) – klargjøring, SSH og fjernutvikling
3. [ESP32](docs/02-esp32.md) – PlatformIO, MicroPython og flashing
4. [Nettverk, data og sky](docs/03-nettverk-og-sky.md) – MQTT, Node-RED, lagring og skytjenester
5. [Elektronikk og sikkerhet](docs/04-elektronikk-og-sikkerhet.md) – strøm, motorer og gode vaner
6. [Konvensjoner](docs/konvensjoner.md) – navngiving, Git og hemmeligheter

## Kom i gang med et nytt prosjekt

Åpne en terminal og kjør:

```bash
~/maker/verktoy/nytt-prosjekt.sh esp32 "Værstasjon ute"
```

Det lager f.eks. `prosjekter/esp32/2026-10-vaerstasjon-ute/` med ferdig mappestruktur og en README du fyller ut. Kjør skriptet uten argumenter for å se hvilke plattformer som finnes.

## Hva verkstedet kan brukes til

Noen eksempler på typer prosjekter oppsettet er laget for:

- Sensornoder med ESP32 som måler temperatur, fukt, lys eller bevegelse og sender data via MQTT.
- Raspberry Pi som sentral: samler data, kjører dashboards og styrer ting i huset.
- Kameraprosjekter: overvåking, tidsforløp, bildegjenkjenning med OpenCV.
- Roboter og motorstyring: DC-motorer, servoer og steppermotorer, fjernstyrt eller autonomt.
- Sky-integrasjon: data til ThingSpeak, Adafruit IO, AWS IoT eller Azure, med varsler og grafer.
