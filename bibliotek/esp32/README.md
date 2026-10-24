# Felles ESP32-kode

Biblioteker som deles mellom ESP32-prosjektene. PlatformIO finner dem via `lib_extra_dirs` i `platformio.ini` (ferdig satt opp i firmware-malen).

| Bibliotek | Innhold |
|---|---|
| [`maker_nett/`](maker_nett/src/maker_nett.h) | Wi-Fi og MQTT: tilkobling, ny tilkobling av seg selv, status `online`/`offline` (Last Will), emner `maker/<sted>/<enhet>/<navn>`, abonnement på kommandoer |
| [`cyd/`](cyd/src/cyd.h) | ESP32-2432S028R «Cheap Yellow Display»: skjerm og berøring (LovyanGFX), RGB-LED, lyssensor, pinneoversikt |

Bruk i et prosjekt:

```cpp
#include <maker_nett.h>
#include <cyd.h>

maker::Nett nett({WIFI_SSID, WIFI_PASSORD, MQTT_VERT, MQTT_PORT,
                  MQTT_BRUKER, MQTT_PASSORD, STED, ENHET});
cyd::Skjerm skjerm;

void setup() { nett.begin(); skjerm.init(); }
void loop()  { nett.loop(); nett.publiser("temperatur", 21.5f); }
```

Nytt bibliotek: lag en mappe med `library.json` og koden i `src/`.
