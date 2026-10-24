# Nettverk, data og sky

## Hovedidé

Enhetene snakker sammen via **MQTT**, en lett meldingsprotokoll. En broker (sentral) tar imot meldinger og videreformidler dem. ESP32-er publiserer målinger, og Pi, PC og skytjenester abonnerer på dem.

```
ESP32-sensorer ──MQTT──► Broker (Mosquitto) ──► Node-RED ──► InfluxDB ──► Grafana
                                │                    │
                                └──► Home Assistant  └──► Skytjeneste / varsler
```

## Lokale tjenester

| Tjeneste | Rolle | Port | Kjører på |
|---|---|---|---|
| Mosquitto | MQTT-broker | 1883 | Pi eller PC (Docker) |
| Node-RED | Visuell flyt: koble sammen data, logikk og varsler | 1880 | Pi eller PC (Docker) |
| InfluxDB | Tidsseriedatabase for målinger | 8086 | Pi eller PC (Docker) |
| Grafana | Grafer og dashboards | 3000 | Pi eller PC (Docker) |
| Home Assistant | Smarthjem, hvis prosjekter skal inn der | 8123 | Egen Pi anbefales |

Mosquitto, Telegraf, InfluxDB, Grafana og Node-RED er **satt opp og testet** med Docker Compose i [`infrastruktur/`](../infrastruktur/README.md) (kjører foreløpig på EliteBooken, skal flyttes til `pi-sentral`). Telegraf lagrer automatisk alt på `maker/<sted>/<enhet>/<navn>` i InfluxDB. Home Assistant er ikke satt opp.

## Teste MQTT fra terminalen

Med `mosquitto-clients` installert på PC-en:

```bash
# Lytt på alt under maker/ (# = alt på alle nivåer under)
mosquitto_sub -h pi-sentral.local -t 'maker/#' -v

# Send en testmelding fra et annet vindu
mosquitto_pub -h pi-sentral.local -t 'maker/stue/esp32-01/temperatur' -m '21.5'
```

Mosquitto 2.x tillater bare tilkoblinger fra samme maskin hvis det ikke er satt opp en `listener` og brukere/passord i konfigurasjonen.

## Navngiving av MQTT-emner (topics)

Fast struktur: `maker/<sted>/<enhet>/<måling>`

```
maker/stue/esp32-01/temperatur
maker/ute/vaerstasjon/fukt
maker/robot/rover/status
```

- Små bokstaver, ingen æ/ø/å, ingen mellomrom (samme regler som filnavn).
- Verdien er et tall eller en kort JSON-streng, f.eks. `{"verdi": 21.5, "enhet": "C"}`.
- Abonner på grupper med jokertegn: `maker/stue/#` (alt i stua) eller `maker/+/+/temperatur` (alle temperaturer).
- Bruk `maker/<sted>/<enhet>/status` med «retained» melding og Last Will (`online`/`offline`) for å se hvilke enheter som er oppe.

## Skytjenester

| Tjeneste | Passer til |
|---|---|
| ThingSpeak | Enkel logging og grafer, rask start, MATLAB-analyser |
| Adafruit IO | Enkle dashboards, hobbyvennlig, har egen MQTT-broker |
| AWS IoT Core | Lære «ekte» IoT-sky med X.509-sertifikater, regler og Lambda |
| Azure IoT Hub | Tilsvarende hos Microsoft, med Device Twins og Stream Analytics |

Sertifikater og nøkler (`*.pem`, `*.key`) står i `.gitignore` og skal aldri sjekkes inn.

Noter kontoer og hvilke prosjekter som bruker hva i tabellen under (ikke passord eller nøkler):

| Tjeneste | Konto / prosjekt | Brukes av |
|---|---|---|
| | | |
