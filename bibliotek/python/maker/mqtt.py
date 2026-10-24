"""MQTT for Pi- og PC-programmer i verkstedet – samme konvensjoner som maker_nett på ESP32.

- Emner: maker/<sted>/<enhet>/<navn>
- Publiserer "online" på .../status ved tilkobling, og broker publiserer "offline"
  (Last Will) hvis programmet forsvinner. Begge er "retained".
- Kobler til på nytt av seg selv.

Bruk:
    from maker.mqtt import Klient
    klient = Klient.fra_miljo()          # leser MQTT_* , STED og ENHET fra miljøet / .env
    klient.ved_melding("kommando/#", lambda emne, innhold: print(emne, innhold))
    klient.start()
    klient.publiser("temperatur", 21.5)
"""

from __future__ import annotations

import logging
import os
from typing import Callable

import paho.mqtt.client as mqtt

log = logging.getLogger(__name__)

MeldingsHandler = Callable[[str, str], None]


class Klient:
    def __init__(self, sted: str, enhet: str, vert: str, port: int = 1883,
                 bruker: str = "", passord: str = ""):
        self.sted = sted
        self.enhet = enhet
        self._abonnementer: dict[str, MeldingsHandler] = {}

        self._mqtt = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id=enhet)
        if bruker:
            self._mqtt.username_pw_set(bruker, passord)
        self._mqtt.will_set(self.emne("status"), "offline", qos=1, retain=True)
        self._mqtt.reconnect_delay_set(min_delay=1, max_delay=30)
        self._mqtt.on_connect = self._ved_tilkobling
        self._mqtt.on_message = self._ved_melding
        self._vert, self._port = vert, port

    @classmethod
    def fra_miljo(cls) -> "Klient":
        """Lager en klient fra miljøvariabler (typisk lastet fra .env)."""
        return cls(
            sted=os.environ["STED"],
            enhet=os.environ["ENHET"],
            vert=os.environ.get("MQTT_VERT", "localhost"),
            port=int(os.environ.get("MQTT_PORT", "1883")),
            bruker=os.environ.get("MQTT_BRUKER", ""),
            passord=os.environ.get("MQTT_PASSORD", ""),
        )

    def emne(self, navn: str) -> str:
        return f"maker/{self.sted}/{self.enhet}/{navn}"

    def start(self) -> None:
        """Kobler til og kjører nettverkstrafikken i en egen tråd."""
        self._mqtt.connect_async(self._vert, self._port, keepalive=60)
        self._mqtt.loop_start()

    def stopp(self) -> None:
        self._mqtt.publish(self.emne("status"), "offline", qos=1, retain=True).wait_for_publish(2)
        self._mqtt.disconnect()
        self._mqtt.loop_stop()

    @property
    def tilkoblet(self) -> bool:
        return self._mqtt.is_connected()

    def publiser(self, navn: str, verdi: object, behold: bool = False) -> None:
        self._mqtt.publish(self.emne(navn), str(verdi), qos=0, retain=behold)

    def ved_melding(self, navn: str, handler: MeldingsHandler) -> None:
        """Abonner på maker/<sted>/<enhet>/<navn>, f.eks. "kommando/#"."""
        self._abonnementer[self.emne(navn)] = handler
        if self.tilkoblet:
            self._mqtt.subscribe(self.emne(navn))

    def _ved_tilkobling(self, klient, _userdata, _flagg, kode, _egenskaper) -> None:
        if kode.is_failure:
            log.warning("MQTT-tilkobling feilet: %s", kode)
            return
        log.info("Koblet til MQTT %s:%s som %s", self._vert, self._port, self.enhet)
        klient.publish(self.emne("status"), "online", qos=1, retain=True)
        for emne in self._abonnementer:
            klient.subscribe(emne)

    def _ved_melding(self, _klient, _userdata, melding: mqtt.MQTTMessage) -> None:
        innhold = melding.payload.decode(errors="replace")
        for filter_, handler in self._abonnementer.items():
            if mqtt.topic_matches_sub(filter_, melding.topic):
                handler(melding.topic, innhold)
