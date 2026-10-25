# Verktøy for Arduino

Hvilke verktøy vi bruker når vi jobber med klassiske Arduino-kort (Uno, Nano, Mega, Leonardo), og til hva. Installasjonsstatus står i [docs/00-oppsett-pc.md](../../docs/00-oppsett-pc.md).

| Verktøy | Brukes til |
|---|---|
| Arduino IDE 2 | Raske tester, eksempler og serieplotter |
| VS Code + PlatformIO IDE | Større prosjekter, samme arbeidsflyt som for ESP32 (`platform = atmelavr`) |
| `dmesg`, `lsusb` | Finne porten: originale Uno/Mega gir `/dev/ttyACM0`, Nano-kloner med CH340 gir `/dev/ttyUSB0` |
| Wokwi Simulator (VS Code eller wokwi.com) | Simulere Uno/Nano/Mega med komponenter før vi kobler opp |
| SimulIDE (valgfri) | Kretssimulator med AVR-prosessorer, kjører lokalt uten nett |

## Verdt å vite

- Mange Arduino-kort bruker **5 V-logikk**. Ikke koble dem direkte til ESP32 eller Pi uten nivåomformer.
- Nano-kloner trenger ofte prosessorvalget «ATmega328P (Old Bootloader)» for å laste opp.
- CH340-kloner rammes av brltty-problemet (se oppsettet av PC-en).
