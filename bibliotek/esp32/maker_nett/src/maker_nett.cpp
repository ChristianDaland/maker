#include "maker_nett.h"

namespace maker {

Nett::Nett(const NettConfig& cfg) : _cfg(cfg), _mqtt(_wifiKlient) {}

void Nett::begin() {
  WiFi.mode(WIFI_STA);
  WiFi.setHostname(_cfg.enhet);
  WiFi.setAutoReconnect(true);
  WiFi.begin(_cfg.wifiSsid, _cfg.wifiPassord);

  _mqtt.setServer(_cfg.mqttVert, _cfg.mqttPort);
  _mqtt.setBufferSize(512);
  _mqtt.setCallback([this](char* emne, uint8_t* data, unsigned int lengde) {
    if (!_handler) return;
    String innhold;
    innhold.reserve(lengde);
    for (unsigned int i = 0; i < lengde; i++) innhold += (char)data[i];
    _handler(String(emne), innhold);
  });
}

void Nett::loop() {
  if (!wifiTilkoblet()) return;  // WiFi kobler til på nytt av seg selv
  if (!_mqtt.connected()) {
    unsigned long na = millis();
    if (_sisteForsok == 0 || na - _sisteForsok >= FORSOK_INTERVALL_MS) {
      _sisteForsok = na;
      kobleTilMqtt();
    }
    return;
  }
  _mqtt.loop();
}

void Nett::kobleTilMqtt() {
  String status = emne("status");
  bool medBruker = _cfg.mqttBruker && _cfg.mqttBruker[0] != '\0';
  bool ok = _mqtt.connect(_cfg.enhet,
                          medBruker ? _cfg.mqttBruker : nullptr,
                          medBruker ? _cfg.mqttPassord : nullptr,
                          status.c_str(), 1, true, "offline");
  if (!ok) return;
  _mqtt.publish(status.c_str(), "online", true);
  for (uint8_t i = 0; i < _antallAbonnementer; i++) {
    _mqtt.subscribe(emne(_abonnementer[i].c_str()).c_str());
  }
}

bool Nett::wifiTilkoblet() const { return WiFi.status() == WL_CONNECTED; }

bool Nett::mqttTilkoblet() { return _mqtt.connected(); }

String Nett::emne(const char* navn) const {
  return String("maker/") + _cfg.sted + "/" + _cfg.enhet + "/" + navn;
}

bool Nett::publiser(const char* navn, const char* verdi, bool behold) {
  if (!_mqtt.connected()) return false;
  return _mqtt.publish(emne(navn).c_str(), verdi, behold);
}

bool Nett::publiser(const char* navn, float verdi, uint8_t desimaler) {
  return publiser(navn, String(verdi, (unsigned int)desimaler).c_str());
}

bool Nett::publiser(const char* navn, long verdi) {
  return publiser(navn, String(verdi).c_str());
}

bool Nett::abonner(const char* navn) {
  if (_antallAbonnementer >= 8) return false;
  _abonnementer[_antallAbonnementer++] = navn;
  if (_mqtt.connected()) return _mqtt.subscribe(emne(navn).c_str());
  return true;
}

void Nett::vedMelding(MeldingsHandler handler) { _handler = handler; }

}  // namespace maker
