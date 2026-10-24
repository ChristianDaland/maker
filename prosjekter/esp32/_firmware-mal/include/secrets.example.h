// Eksempel – kopier til secrets.h og fyll inn. secrets.h sjekkes ALDRI inn i Git.
// (nytt-prosjekt.sh lager secrets.h automatisk fra denne filen.)
#pragma once

#define WIFI_SSID     ""
#define WIFI_PASSORD  ""

// MQTT-broker: PC-en under testing, pi-sentral når den er satt opp.
// ESP32 forstår ikke alltid .local-navn – bruk IP-adressen hvis tilkoblingen feiler.
#define MQTT_VERT     "pi-sentral.local"
#define MQTT_PORT     1883
#define MQTT_BRUKER   ""
#define MQTT_PASSORD  ""
