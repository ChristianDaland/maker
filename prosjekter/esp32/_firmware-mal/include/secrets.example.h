// Eksempel – kopier til secrets.h og fyll inn. secrets.h sjekkes ALDRI inn i Git.
// (nytt-prosjekt.sh lager secrets.h automatisk og fyller inn verdiene fra
//  ~/maker/verktoy/sd-kort.env og ~/maker/infrastruktur/.env hvis de finnes.)
#pragma once

#define WIFI_SSID     ""
#define WIFI_PASSORD  ""

// MQTT-broker. mqtt.local annonseres av maskinen som kjører broker
// (infrastruktur/mqtt-navn.sh), så kortene trenger ikke endres når broker flyttes.
#define MQTT_VERT     "mqtt.local"
#define MQTT_PORT     1883
#define MQTT_BRUKER   ""
#define MQTT_PASSORD  ""

// Passord for oppdatering over Wi-Fi (OTA). Tomt = OTA av.
#define OTA_PASSORD   ""
