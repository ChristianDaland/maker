# Firmware-filer

Nedlastede firmware-filer for flashing. Selve filene (`*.bin`, `*.uf2`) er gitignored. Last dem ned på nytt fra kildene under ved behov.

| Fil | Til | Kilde |
|---|---|---|
| `ESP32_GENERIC-20260824-v1.29.0.bin` | MicroPython 1.29.0 for ESP32 (også CYD-kortene) | [micropython.org/download/ESP32_GENERIC](https://micropython.org/download/ESP32_GENERIC/) |

Flash MicroPython til en ESP32 (sletter alt som ligger på kortet):

```bash
esptool --port /dev/ttyUSB0 erase-flash
esptool --port /dev/ttyUSB0 --baud 460800 write-flash 0x1000 ~/maker/verktoy/firmware/ESP32_GENERIC-20260824-v1.29.0.bin
```

Tilbake til PlatformIO/Arduino: bare last opp et PlatformIO-prosjekt igjen (`pio run -t upload`).
