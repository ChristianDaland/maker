# Logg

Kort dagbok over arbeid i verkstedet. Nyeste øverst.

## 2026-10-24
- Standard filer innført: `verktoy.md` i hver plattformmappe, og prosjektmalens `README.md` har fått delen «Slik henger det sammen» (deler, dataflyt, kobling).
- Prosjekter organisert per plattform: `prosjekter/{raspberry-pi,esp32,arduino,pico,pc-og-sky,kombinert}/`. `nytt-prosjekt.sh` tar nå plattform som første argument.
- Rammeverket fra `Maker.zip` (laget for Windows) tilpasset Linux Mint og lagt i `~/maker`.
- Skrevet om docs for Linux: seriellporter, dialout, brltty, udev, pipx/venv, ssh-copy-id.
- `nytt-prosjekt.ps1` erstattet med `verktoy/nytt-prosjekt.sh`.
- Lagt til `CLAUDE.md`.
- Kartlagt PC-en: git, Python 3.12 og VS Code finnes. Ikke i `dialout`, brltty installert. Resten av verktøyene mangler (se `docs/00-oppsett-pc.md`).
- Git-repo initialisert.
