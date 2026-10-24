// Startpunkt for et ESP32-prosjekt i verkstedet.
//
// Gjør dette fra start:
// - kobler til Wi-Fi og MQTT (bibliotek/esp32/maker_nett)
// - sender lysnivå og signalstyrke hvert MALEINTERVALL_MS til maker/<sted>/<enhet>/...
// - viser status på skjermen og med RGB-LED (bare på CYD, env:cyd)
// - sender berøringer som JSON til maker/<sted>/<enhet>/beroring
//
// Bygg videre herfra: legg til sensorer, egne meldinger og logikk.
#include <Arduino.h>
#include <ArduinoJson.h>
#include <maker_nett.h>

#include "config.h"
#include "secrets.h"

#ifdef MED_SKJERM
#include <cyd.h>
cyd::Skjerm skjerm;
#endif

maker::Nett nett({WIFI_SSID, WIFI_PASSORD, MQTT_VERT, MQTT_PORT,
                  MQTT_BRUKER, MQTT_PASSORD, STED, ENHET});

unsigned long sisteMaling = 0;

#ifdef MED_SKJERM
void tegnStatus() {
  static int forrigeTilstand = -1;
  int tilstand = (nett.wifiTilkoblet() ? 1 : 0) + (nett.mqttTilkoblet() ? 2 : 0);
  if (tilstand == forrigeTilstand) return;
  forrigeTilstand = tilstand;

  skjerm.fillRect(0, 40, skjerm.width(), 60, TFT_BLACK);
  skjerm.setTextSize(2);
  skjerm.setCursor(10, 45);
  skjerm.setTextColor(nett.wifiTilkoblet() ? TFT_GREEN : TFT_RED, TFT_BLACK);
  skjerm.printf("Wi-Fi: %s", nett.wifiTilkoblet() ? WiFi.localIP().toString().c_str() : "kobler til...");
  skjerm.setCursor(10, 70);
  skjerm.setTextColor(nett.mqttTilkoblet() ? TFT_GREEN : TFT_RED, TFT_BLACK);
  skjerm.printf("MQTT:  %s", nett.mqttTilkoblet() ? "tilkoblet" : "venter...");

  cyd::led(!nett.mqttTilkoblet(), nett.mqttTilkoblet(), false);
}
#endif

void setup() {
  Serial.begin(115200);
  Serial.printf("\n%s starter (%s)\n", ENHET, STED);

#ifdef MED_SKJERM
  cyd::ledInit();
  cyd::led(false, false, true);  // blå = starter
  skjerm.init();
  skjerm.setRotation(1);
  skjerm.fillScreen(TFT_BLACK);
  skjerm.setTextColor(TFT_WHITE, TFT_BLACK);
  skjerm.setTextSize(2);
  skjerm.setCursor(10, 10);
  skjerm.printf("%s / %s", ENHET, STED);
#endif

  nett.vedMelding([](const String& emne, const String& innhold) {
    Serial.printf("Melding: %s = %s\n", emne.c_str(), innhold.c_str());
  });
  nett.abonner("kommando/#");
  nett.begin();
}

void loop() {
  nett.loop();

  unsigned long na = millis();
  if (na - sisteMaling >= MALEINTERVALL_MS) {
    sisteMaling = na;
    nett.publiser("rssi", (long)WiFi.RSSI());
#ifdef MED_SKJERM
    nett.publiser("lys", (long)cyd::lysniva());
#endif
  }

#ifdef MED_SKJERM
  tegnStatus();

  int32_t x, y;
  static unsigned long sisteBeroring = 0;
  if (skjerm.getTouch(&x, &y) && na - sisteBeroring > 300) {
    sisteBeroring = na;
    skjerm.fillCircle(x, y, 4, TFT_YELLOW);
    JsonDocument doc;
    doc["x"] = x;
    doc["y"] = y;
    char tekst[64];
    serializeJson(doc, tekst);
    nett.publiser("beroring", tekst);
  }
#endif
}
