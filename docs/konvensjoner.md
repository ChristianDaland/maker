# Konvensjoner

## Navngiving

- Mapper og filnavn: små bokstaver, bindestrek i stedet for mellomrom, ingen æ, ø, å. Eksempel: `vaerstasjon-ute`. Inne i dokumentene skriver vi vanlig norsk med æ, ø og å.
- Prosjektmapper starter med år og måned (`ÅÅÅÅ-MM-navn`): `2026-10-vaerstasjon-ute`. Da sorteres de kronologisk. Bruk `verktoy/nytt-prosjekt.sh`, så blir det riktig automatisk.
- Enheter navngis etter type og nummer eller rolle: `esp32-01`, `esp32-02`, `pi-sentral`, `pi-kamera`. Samme navn brukes som hostname, i MQTT-emner og i dokumentasjonen.

## Git

- Hele `~/maker` er ett Git-repo. Skill ut prosjekter som vokser seg store til egne repoer.
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

- Hvert prosjekt har en `README.md` basert på malen.
- Skriv ned hva som ikke fungerte også, ikke bare løsningen. Det sparer tid neste gang.
- Kort logg over arbeid føres i `notater/logg.md`, nyeste øverst.
