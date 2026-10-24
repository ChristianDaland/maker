# Konvensjoner

## Navngiving

- Mapper og filnavn: små bokstaver, bindestrek i stedet for mellomrom, ingen æ, ø, å. Eksempel: `vaerstasjon-ute`. Inne i dokumentene skriver vi vanlig norsk med æ, ø og å.
- Prosjekter ligger under en plattformmappe: `prosjekter/<plattform>/` der plattform er `raspberry-pi`, `esp32`, `arduino`, `pico`, `pc-og-sky`, `kombinert` eller `reparasjon`. Prosjekter som bruker flere plattformer, legges i `kombinert/`.
- Prosjektmapper starter med år og måned (`ÅÅÅÅ-MM-navn`): `prosjekter/esp32/2026-10-vaerstasjon-ute`. Da sorteres de kronologisk. Bruk `verktoy/nytt-prosjekt.sh <plattform> "Navn"`, så blir det riktig automatisk.
- Enheter navngis etter type og nummer eller rolle: `esp32-01`, `esp32-02`, `pi-sentral`, `pi-kamera`. Samme navn brukes som hostname, i MQTT-emner og i dokumentasjonen.

## Git

- Hele `~/maker` er ett Git-repo, publisert som **offentlig** repo på [github.com/ChristianDaland/maker](https://github.com/ChristianDaland/maker). Plattformene er mapper i repoet, slik som lokalt.
- Fordi repoet er offentlig: ikke skriv passord, nøkler, IP-adresser utenfra, Wi-Fi-navn, adresse eller serienumre i filer som sjekkes inn.
- Skill ut prosjekter som vokser seg store til egne repoer med navnet `<plattform>-<prosjekt>` (f.eks. `esp32-vaerstasjon`) og topics `maker` + plattform, og lenk til dem fra plattformens `README.md`.
- Commit ofte, med korte meldinger på norsk som forteller hva som er endret.
- Byggemapper (`.pio/`, `__pycache__/`, `.venv/`) står i `.gitignore`.

## Hemmeligheter

Passord, Wi-Fi-detaljer, API-nøkler og sertifikater skal **aldri** inn i Git.

- Legg dem i filer som heter `secrets.*` (f.eks. `secrets.h`, `secrets.py`) eller `.env`. Disse står allerede i `.gitignore`, sammen med `*.pem` og `*.key`.
- Lag en eksempelfil (`secrets.example.h`, `secrets.example.py`, `.env.example`) som viser hvilke verdier som trengs, uten de ekte verdiene. Eksempelfilene sjekkes inn.
- Sjekk med `git status` før commit at ingen hemmeligheter er med.

## Python

- Ett virtuelt miljø per prosjekt (`.venv/`), aldri `pip install` i systemets Python.
- Avhengigheter i `requirements.txt`.
- Kommandolinjeverktøy installeres med `pipx`.

## Dokumentasjon

Standard filer som alltid skal finnes:

| Hvor | Fil | Innhold |
|---|---|---|
| Hver plattformmappe (`prosjekter/<plattform>/`) | `README.md` | Hva slags prosjekter som hører hjemme her |
| Hver plattformmappe | `verktoy.md` | Hvilke verktøy vi bruker for plattformen, og til hva |
| Hvert prosjekt | `README.md` | Hva prosjektet er, **hvordan det henger sammen** (deler, dataflyt, kobling), og hvordan det kjøres |

- Ny plattform: lag mappen med både `README.md` og `verktoy.md` før første prosjekt.
- En plattform kan ha en `_firmware-mal/` som `nytt-prosjekt.sh` kopierer til prosjektets `firmware/` (finnes for `esp32`).
- Prosjektets `README.md` lages fra malen av `nytt-prosjekt.sh`. Hold delen «Slik henger det sammen» oppdatert når noe endres.
- Skriv ned hva som ikke fungerte også, ikke bare løsningen. Det sparer tid neste gang.
- Kort logg over arbeid føres i `notater/logg.md`, nyeste øverst.
