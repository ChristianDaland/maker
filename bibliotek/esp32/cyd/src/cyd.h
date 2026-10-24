// cyd – ESP32-2432S028R «Cheap Yellow Display»
//
// Skjerm: 2,8" 320×240, ILI9341 på HSPI. Berøring: XPT2046 (resistiv) på VSPI.
// Pinner fra https://github.com/witnessmenow/ESP32-Cheap-Yellow-Display
//
// Noen kort (ofte de med to USB-porter, «CYD2USB») har ST7789-skjerm i stedet.
// Får du feil farger eller speilvendt bilde, legg til -DCYD_ST7789 i build_flags.
//
// Bruk:
//   #include <cyd.h>
//   cyd::Skjerm skjerm;
//   skjerm.init(); skjerm.setRotation(1);   // liggende, USB til venstre
//   int32_t x, y; if (skjerm.getTouch(&x, &y)) { ... }
#pragma once

#define LGFX_USE_V1
#include <Arduino.h>
#include <LovyanGFX.hpp>

namespace cyd {

// RGB-LED på baksiden. Aktiv LAV: LOW = på.
constexpr uint8_t LED_ROD = 4;
constexpr uint8_t LED_GRONN = 16;
constexpr uint8_t LED_BLA = 17;

// Lyssensor (LDR), analog inngang. Lavere verdi = mer lys.
constexpr uint8_t LYSSENSOR = 34;

// Høyttalerutgang (via forsterker, kontakt P4)
constexpr uint8_t HOYTTALER = 26;

// BOOT-knappen kan brukes som vanlig knapp etter oppstart (LOW = trykket)
constexpr uint8_t KNAPP_BOOT = 0;

// Ledige pinner på kontaktene P3 og CN1 (for sensorer o.l.)
constexpr uint8_t LEDIG_IO22 = 22;
constexpr uint8_t LEDIG_IO27 = 27;
constexpr uint8_t LEDIG_IO35 = 35;  // kun inngang, ingen intern pull-up

// SD-kort (VSPI): SCK 18, MISO 19, MOSI 23, CS 5

inline void ledInit() {
  pinMode(LED_ROD, OUTPUT);
  pinMode(LED_GRONN, OUTPUT);
  pinMode(LED_BLA, OUTPUT);
}

inline void led(bool rod, bool gronn, bool bla) {
  digitalWrite(LED_ROD, rod ? LOW : HIGH);
  digitalWrite(LED_GRONN, gronn ? LOW : HIGH);
  digitalWrite(LED_BLA, bla ? LOW : HIGH);
}

inline int lysniva() { return analogRead(LYSSENSOR); }

class Skjerm : public lgfx::LGFX_Device {
#ifdef CYD_ST7789
  lgfx::Panel_ST7789 _panel;
#else
  lgfx::Panel_ILI9341 _panel;
#endif
  lgfx::Bus_SPI _bus;
  lgfx::Light_PWM _lys;
  lgfx::Touch_XPT2046 _beroring;

 public:
  Skjerm() {
    {
      auto cfg = _bus.config();
      cfg.spi_host = HSPI_HOST;
      cfg.spi_mode = 0;
      cfg.freq_write = 40000000;
      cfg.freq_read = 16000000;
      cfg.spi_3wire = false;
      cfg.use_lock = true;
      cfg.dma_channel = SPI_DMA_CH_AUTO;
      cfg.pin_sclk = 14;
      cfg.pin_mosi = 13;
      cfg.pin_miso = 12;
      cfg.pin_dc = 2;
      _bus.config(cfg);
      _panel.setBus(&_bus);
    }
    {
      auto cfg = _panel.config();
      cfg.pin_cs = 15;
      cfg.pin_rst = -1;
      cfg.pin_busy = -1;
      cfg.panel_width = 240;
      cfg.panel_height = 320;
      cfg.offset_x = 0;
      cfg.offset_y = 0;
      cfg.offset_rotation = 0;
      cfg.readable = true;
      cfg.invert = false;  // sett til true hvis fargene er invertert (negativ)
      cfg.rgb_order = false;
      cfg.dlen_16bit = false;
      cfg.bus_shared = false;
      _panel.config(cfg);
    }
    {
      auto cfg = _lys.config();
      cfg.pin_bl = 21;
      cfg.invert = false;
      cfg.freq = 12000;
      cfg.pwm_channel = 7;
      _lys.config(cfg);
      _panel.setLight(&_lys);
    }
    {
      // Kalibreringsverdier er omtrentlige. Bruk calibrateTouch() for nøyaktig kalibrering.
      auto cfg = _beroring.config();
      cfg.x_min = 300;
      cfg.x_max = 3900;
      cfg.y_min = 200;
      cfg.y_max = 3700;
      cfg.pin_int = 36;
      cfg.bus_shared = false;
      cfg.offset_rotation = 0;
      cfg.spi_host = VSPI_HOST;
      cfg.freq = 1000000;
      cfg.pin_sclk = 25;
      cfg.pin_mosi = 32;
      cfg.pin_miso = 39;
      cfg.pin_cs = 33;
      _beroring.config(cfg);
      _panel.setTouch(&_beroring);
    }
    setPanel(&_panel);
  }
};

}  // namespace cyd
