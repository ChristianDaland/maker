# {{NAVN}}

Plattform: {{PLATTFORM}}
Startet: {{DATO}}
Status: idé / pågår / fungerer / lagt på is

## Hva og hvorfor

Kort beskrivelse av hva prosjektet skal gjøre og hvorfor det er interessant.

## Slik henger det sammen

Oversikt over delene og hvordan de snakker sammen. Tegn gjerne en enkel skisse:

```
[sensor] --I2C--> [esp32-01] --Wi-Fi/MQTT--> [pi-sentral] --> [Grafana]
```

### Deler og enheter

| Del | Enhet / sted | Rolle | Kode |
|---|---|---|---|
| | | | `firmware/` / `pi/` |

### Dataflyt

Hva sendes hvor, hvor ofte og i hvilket format.

| Fra | Til | Hvordan (MQTT-emne, seriell, HTTP …) | Innhold / format |
|---|---|---|---|
| | | `maker/<sted>/<enhet>/<måling>` | |

### Kobling

Hvordan komponentene er koblet fysisk. Koblingsskjema og bilder legges i `hardware/`.

| Fra (komponent, pinne) | Til (komponent, pinne) | Merknad |
|---|---|---|
| | | |

Strøm: hva drives av hva, og hvor er felles jord?

## Maskinvare

| Komponent | Antall | Merknad |
|---|---|---|
| | | |

## Programvare og mapper

- `firmware/` – kode for mikrokontroller (ESP32, Arduino, Pico)
- `pi/` – kode som kjører på Raspberry Pi
- `hardware/` – koblingsskjema, bilder, KiCad/Fritzing-filer
- `docs/` – utfyllende notater, datablad som bare gjelder dette prosjektet
- Hemmeligheter: `secrets.*` / `.env` (gitignored), med eksempelfil ved siden av
- Avhenger av felles tjenester / biblioteker:

## Slik kjører du det

1. 

## Logg og lærdom

- {{DATO}}: Prosjekt opprettet.

## Videre ideer

- 
