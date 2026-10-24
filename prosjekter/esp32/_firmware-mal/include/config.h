// Innstillinger for denne enheten. Sjekkes inn i Git (ingen hemmeligheter her).
#pragma once

// Navn på enheten: hostname, MQTT-klient-ID og del av MQTT-emnet.
// Se docs/02-esp32.md for hvilke navn som er i bruk.
#define ENHET "esp32-01"

// Hvor enheten står: maker/<STED>/<ENHET>/<navn>
#define STED "verksted"

// Hvor ofte målinger sendes (millisekunder)
#define MALEINTERVALL_MS 10000
