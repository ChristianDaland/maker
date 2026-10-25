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
| Wokwi Simulator (VS Code) | Simulere ESP32 med skjerm, LED, lyssensor og MQTT mot PC-en, uten kort. Ferdig satt opp i malen (`diagram.json`, `wokwi.toml`, `env:wokwi`) |

## Vanlige biblioteker (PlatformIO)

| Bibliotek | Brukes til |
|---|---|
| `knolleary/PubSubClient` | MQTT-klient |
| `bblanchon/ArduinoJson` | Lage og lese JSON-meldinger |
| `WiFi` (innebygd) | Wi-Fi-tilkobling |
| `lovyan03/LovyanGFX` | Skjerm og berøring på CYD-kortene |
| `maker_nett` (vårt eget) | Wi-Fi + MQTT etter verkstedets konvensjoner |
| `cyd` (vårt eget) | Pinner, skjerm, LED og lyssensor på CYD-kortene |

Firmware-malen i [`_firmware-mal/`](_firmware-mal/) har alt dette ferdig satt opp. Se [docs/02-esp32.md](../../docs/02-esp32.md#nytt-esp32-prosjekt).

Hemmeligheter: `firmware/include/secrets.h` (gitignored) med `secrets.example.h` ved siden av.
