# Verktøy for kombinerte prosjekter

Kombinerte prosjekter bruker verktøyene for hver plattform som er med. Se:

- [raspberry-pi/verktoy.md](../raspberry-pi/verktoy.md)
- [esp32/verktoy.md](../esp32/verktoy.md)
- [arduino/verktoy.md](../arduino/verktoy.md)
- [pico/verktoy.md](../pico/verktoy.md)
- [pc-og-sky/verktoy.md](../pc-og-sky/verktoy.md)

I tillegg bruker vi dette for å få delene til å snakke sammen:

| Verktøy | Brukes til |
|---|---|
| MQTT (Mosquitto) | Felles meldingskanal mellom enhetene, emner `maker/<sted>/<enhet>/<måling>` |
| `mosquitto-clients` | Se trafikken mellom delene: `mosquitto_sub -t 'maker/#' -v` |
| Node-RED | Koble sammen data, logikk og varsler visuelt |
| `infrastruktur/` | Felles broker, database og dashboards (Docker Compose) |
| Git | Alle deler i samme prosjektmappe: `firmware/`, `pi/`, `docs/` |
