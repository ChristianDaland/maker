# PlayStation 4

Plattform: reparasjon
Startet: 2026-10-24
Status: lagt på is – vinterprosjekt 2026/27 (konsollen er demontert)

## Hva og hvorfor

Reparere en PlayStation 4.

| | |
|---|---|
| Modell | _(Original/Slim/Pro, modellnummer CUH-xxxx står under konsollen)_ |
| Serienummer | |
| Symptom | _(Hva skjer? F.eks. blått lys som blinker, starter ikke, overoppheting, ikke bilde på HDMI, lager støy, leser ikke plater)_ |
| Når startet det | |
| Tidligere reparasjoner | |

## Slik henger det sammen

Hoveddelene i konsollen og hvordan de henger sammen. Det gjør det lettere å se hvor feilen kan sitte.

```
230 V ──> [strømforsyning (PSU)] ──12 V──> [hovedkort: APU + minne + HDMI-kontakt]
                                                 │         │          │
                                     [harddisk/SSD]   [vifte + kjøleribbe]   [Blu-ray-stasjon]
                                                 │
                                    [Wi-Fi/Bluetooth] ── [kontroller]
```

### Deler

| Del | Tilstand | Merknad |
|---|---|---|
| Strømforsyning (PSU) | mistenkt defekt | Ikke målt ennå |
| Hovedkort / APU | ukjent | |
| HDMI-kontakt | ukjent | Vanlig feilkilde |
| Harddisk | ukjent | |
| Vifte og kjøleribbe | ukjent | Ny kjølepasta på APU skal på ved montering |
| Blu-ray-stasjon | ukjent | |

## Feilsøking

Hva er testet, hva ble resultatet, og hva bør testes neste gang. Nyeste nederst.

| Dato | Test / måling | Resultat |
|---|---|---|
| 2026-10-24 | Konsollen demontert | PSU mistenkt defekt, ikke bekreftet med måling |

## Demontering

- Ta bilde av hvert trinn og legg i `hardware/`.
- Noter skruetype og plassering (sikkerhets-Torx og Phillips i ulike lengder).

## Plan for vinteren

- [ ] Fyll inn modell (CUH-nummer) og symptom over, før vi bestiller deler
- [ ] Mål PSU med multimeter for å bekrefte at den er defekt (**PSU har 230 V og kondensatorer som kan holde på spenningen. Ikke mål med strøm tilkoblet før vi har gått gjennom fremgangsmåten**)
- [ ] Bestill ny PSU som passer modellnummeret
- [ ] Bestill kjølepasta (og termiske puter hvis de gamle er ødelagte)
- [ ] Rens APU og kjøleribbe med isopropanol, påfør ny kjølepasta
- [ ] Rens vifte og kjøleribbe for støv
- [ ] Monter sammen igjen, trinn for trinn (Claude hjelper til)
- [ ] Test: oppstart, bilde på HDMI, temperatur og viftestøy

## Mens den ligger demontert

- Legg skruene i merkede poser eller beholdere, sortert etter hvor de satt.
- Ta bilder av det som er demontert (kabler, flatkabler, skruer) mens du husker hvordan det satt, og legg dem i `hardware/`.
- Oppbevar hovedkortet i en antistatisk pose.

## Deler og innkjøp

| Del | Fra | Pris | Status |
|---|---|---|---|
| | | | |

## Mapper

- `hardware/` – bilder fra demontering, målinger og koblingsdetaljer
- `docs/` – servicemanualer, guider og datablad

Verktøy: se [verktoy.md](../verktoy.md).

## Logg og lærdom

- 2026-10-24: Prosjekt opprettet. Konsollen er tatt fra hverandre. PSU er mistenkt defekt, og det trengs ny kjølepasta. Montering og reparasjon er utsatt til vinteren.
