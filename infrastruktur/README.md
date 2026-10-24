# Infrastruktur

Her dokumenteres og konfigureres felles tjenester som flere prosjekter bruker: MQTT-broker (Mosquitto), Node-RED, InfluxDB og Grafana.

Planen er å kjøre dem med Docker Compose, enten på EliteBooken for testing eller på en Raspberry Pi som fast sentral. Tanken er én `compose.yaml` her, og én undermappe per tjeneste for konfigurasjon og data:

```
infrastruktur/
├── compose.yaml
├── .env.example        # passord og tokens (ekte .env sjekkes ikke inn)
├── mosquitto/config/mosquitto.conf
├── nodered/
├── influxdb/
└── grafana/
```

Status: **ikke satt opp ennå**. Krever Docker Engine (se [oppsett av PC-en](../docs/00-oppsett-pc.md)). Se [nettverk og sky](../docs/03-nettverk-og-sky.md) for oversikten.
