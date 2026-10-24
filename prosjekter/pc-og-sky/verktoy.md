# Verktøy for PC og sky

Hvilke verktøy vi bruker for prosjekter som kjører på EliteBooken eller i skyen, og til hva. Installasjonsstatus står i [docs/00-oppsett-pc.md](../../docs/00-oppsett-pc.md). Mer om sky står i [docs/03-nettverk-og-sky.md](../../docs/03-nettverk-og-sky.md).

| Verktøy | Brukes til |
|---|---|
| Python 3 + `venv` | Skript, dataanalyse og MQTT-klienter, ett `.venv` per prosjekt |
| VS Code + Python-utvidelsen | Editor og feilsøking |
| `paho-mqtt` | MQTT fra Python |
| `pandas`, `matplotlib`, `numpy` | Analysere og plotte måledata |
| `opencv-python` | Bildebehandling og bildegjenkjenning |
| `mosquitto-clients` | Teste MQTT fra terminalen (`mosquitto_sub`, `mosquitto_pub`) |
| Docker + Compose | Kjøre tjenester lokalt (se `infrastruktur/`) |
| Skyens egne CLI-er (`aws`, `az`) | Bare når et prosjekt bruker AWS IoT eller Azure IoT. Installeres da |

Nøkler og sertifikater ligger i `.env`, `secrets.*`, `*.pem` og `*.key`, og alle disse er gitignored.
