# Maker – hobbyverksted på EliteBook

Dette er det faste området på maskinen for alle hobbyprosjekter med Raspberry Pi, ESP32, sensorer, motorer, kamera, roboter og kombinasjoner av elektronikk, data og sky.

Alt som har med disse prosjektene å gjøre, bor her: kode, koblingsskjemaer, notater, datablad og oppsett av tjenester. Målet er at det skal være lett å finne igjen ting, lett å starte nye prosjekter, og lett å gjenbruke det som allerede fungerer.

## Plassering

Rotmappen er `~/maker` (`/home/odd_christian/maker`) på en HP EliteBook med Linux Mint. Stien er kort og har verken mellomrom eller æ, ø, å, noe som unngår trøbbel med PlatformIO og andre byggeverktøy.

Sikkerhetskopi og deling håndteres med Git (og etter hvert GitHub).

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

```
prosjekter/
├── _mal/            mal som kopieres for hvert nytt prosjekt
├── raspberry-pi/    kjører på en Raspberry Pi
├── esp32/           ESP32 som hovedenhet
├── arduino/         Arduino Uno, Nano, Mega osv.
├── pico/            Raspberry Pi Pico (RP2040/RP2350)
├── pc-og-sky/       kjører på PC-en eller i skyen, uten mikrokontroller
└── kombinert/       flere plattformer sammen, f.eks. ESP32-sensorer + Pi-sentral
```

Under hver plattform ligger én mappe per prosjekt, f.eks. `prosjekter/esp32/2026-10-vaerstasjon-ute/`. Trengs en ny plattform, lag en ny mappe i `prosjekter/` med en kort `README.md`, så kjenner skriptet den igjen automatisk.

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
