# Verktøy for Raspberry Pi Pico

Hvilke verktøy vi bruker når vi jobber med Raspberry Pi Pico / Pico W / Pico 2 (RP2040/RP2350), og til hva. Installasjonsstatus står i [docs/00-oppsett-pc.md](../../docs/00-oppsett-pc.md).

| Verktøy | Brukes til |
|---|---|
| MicroPython (UF2-fil) | **Hovedvalg.** Hold BOOTSEL inne mens Pico kobles til, og dra `.uf2`-filen over på disken `RPI-RP2` |
| Thonny | Laste opp `.py`-filer og bruke REPL (tolk «MicroPython (Raspberry Pi Pico)») |
| `mpremote` (via pipx) | Det samme fra terminalen: `mpremote cp main.py :`, `mpremote repl` |
| VS Code + Raspberry Pi Pico-utvidelsen | C/C++ med Pico SDK, når vi trenger fart eller PIO |
| PlatformIO | Alternativ for Arduino-rammeverket på Pico |
| `picotool` | Lese informasjon fra og flashe Pico fra terminalen |

## Verdt å vite

- Pico dukker opp som `/dev/ttyACM0` når MicroPython kjører.
- 3,3 V-logikk, som ESP32 og Pi.
- Pico W har Wi-Fi og kan sende MQTT med `umqtt.simple`.
