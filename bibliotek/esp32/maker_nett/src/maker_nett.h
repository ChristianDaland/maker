// maker_nett – Wi-Fi og MQTT for ESP32-enhetene i verkstedet.
//
// - Kobler til Wi-Fi og MQTT, og kobler til på nytt av seg selv uten å blokkere loop().
// - Emner følger konvensjonen maker/<sted>/<enhet>/<navn>.
// - Publiserer "online" på maker/<sted>/<enhet>/status ved tilkobling, og broker
//   publiserer "offline" (Last Will) hvis enheten forsvinner. Begge er "retained".
// - Annonserer enheten som <enhet>.local (mDNS), og slår opp .local-navn som
//   «mqtt.local» selv (ESP32 gjør ikke det av seg selv).
// - Oppdatering over Wi-Fi (ArduinoOTA) hvis otaPassord er satt.
//
// Bruk:
//   maker::Nett nett({WIFI_SSID, WIFI_PASSORD, MQTT_VERT, MQTT_PORT,
//                     MQTT_BRUKER, MQTT_PASSORD, "stue", "esp32-01"});
//   void setup() { nett.begin(); }
//   void loop()  { nett.loop(); nett.publiser("temperatur", 21.5); }
#pragma once

#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <IPAddress.h>
#include <functional>

namespace maker {

struct NettConfig {
  const char* wifiSsid;
  const char* wifiPassord;
  const char* mqttVert;
  uint16_t mqttPort;
  const char* mqttBruker;   // tom streng = uten innlogging
  const char* mqttPassord;
  const char* sted;         // f.eks. "stue"
  const char* enhet;        // f.eks. "esp32-01" – brukes også som hostname og MQTT-klient-ID
  const char* otaPassord = nullptr;  // tom/nullptr = OTA av
};

using MeldingsHandler = std::function<void(const String& emne, const String& innhold)>;

class Nett {
 public:
  explicit Nett(const NettConfig& cfg);

  void begin();
  void loop();

  bool wifiTilkoblet() const;
  bool mqttTilkoblet();

  // maker/<sted>/<enhet>/<navn>
  String emne(const char* navn) const;

  bool publiser(const char* navn, const char* verdi, bool behold = false);
  bool publiser(const char* navn, float verdi, uint8_t desimaler = 1);
  bool publiser(const char* navn, long verdi);

  // Abonner på maker/<sted>/<enhet>/<navn>, f.eks. "kommando/#".
  // Abonnementer fornyes automatisk ved ny tilkobling.
  bool abonner(const char* navn);
  void vedMelding(MeldingsHandler handler);

  PubSubClient& klient() { return _mqtt; }

 private:
  void kobleTilMqtt();
  void startNettjenester();

  NettConfig _cfg;
  WiFiClient _wifiKlient;
  PubSubClient _mqtt;
  MeldingsHandler _handler;
  String _abonnementer[8];
  uint8_t _antallAbonnementer = 0;
  unsigned long _sisteForsok = 0;
  bool _nettjenesterStartet = false;
  bool _ota = false;
  IPAddress _mqttIp;
  static constexpr unsigned long FORSOK_INTERVALL_MS = 5000;
};

}  // namespace maker
