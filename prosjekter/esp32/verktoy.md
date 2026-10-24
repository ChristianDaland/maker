# Verktøy for ESP32

Hvilke verktøy vi bruker når vi jobber med ESP32, og til hva. Installasjonsstatus står i [docs/00-oppsett-pc.md](../../docs/00-oppsett-pc.md). Fremgangsmåter står i [docs/02-esp32.md](../../docs/02-esp32.md).

| Verktøy | Brukes til |
|---|---|
| VS Code + PlatformIO IDE | **Hovedvalg.** Bygge, laste opp og overvåke C++-kode (Arduino-rammeverket), med `platformio.ini` per prosjekt |
| PlatformIO CLI (`pio`) | Det samme fra terminalen: `pio run -t upload`, `pio device monitor` |
| MicroPython | Python direkte på ESP32, for rask utprøving |
| Thonny | Flashe MicroPython, laste opp `.py`-filer og bruke REPL |
| esptool (via pipx) | Flashe firmware, slette flash, lese chip-ID og feilsøke tilkobling |
| `dmesg`, `lsusb` | Se om kortet blir funnet og hvilken USB-brikke det har (CP210x/CH340) |
| Wokwi (nettleser) | Simulere ESP32 og koblinger før vi kobler opp på ekte |

## Vanlige biblioteker (PlatformIO)

| Bibliotek | Brukes til |
|---|---|
| `knolleary/PubSubClient` | MQTT-klient |
| `bblanchon/ArduinoJson` | Lage og lese JSON-meldinger |
| `WiFi` (innebygd) | Wi-Fi-tilkobling |
| Felles kode i `bibliotek/esp32/` | Vårt eget, via `lib_extra_dirs` |

Hemmeligheter: `firmware/include/secrets.h` (gitignored) med `secrets.example.h` ved siden av.
