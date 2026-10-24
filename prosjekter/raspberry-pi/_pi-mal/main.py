"""Startpunkt for et Python-prosjekt i verkstedet (Raspberry Pi eller PC).

Gjør dette fra start:
- kobler til MQTT med innstillinger fra .env
- sender CPU-temperatur hvert MALEINTERVALL sekund til maker/<sted>/<enhet>/cpu-temperatur
- skriver ut meldinger som kommer på maker/<sted>/<enhet>/kommando/#

Kjør:
    python3 -m venv .venv
    .venv/bin/pip install -r requirements.txt
    .venv/bin/python main.py
"""

import logging
import os
import signal
import sys
import time
from pathlib import Path

from dotenv import load_dotenv

# Felles kode i ~/maker/bibliotek/python
MAKER_ROT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(MAKER_ROT / "bibliotek" / "python"))
from maker.mqtt import Klient  # noqa: E402

load_dotenv(Path(__file__).with_name(".env"))
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("main")

MALEINTERVALL = float(os.environ.get("MALEINTERVALL", "10"))


def cpu_temperatur() -> float | None:
    """CPU-temperatur i °C (virker på Raspberry Pi og de fleste Linux-PC-er)."""
    try:
        return int(Path("/sys/class/thermal/thermal_zone0/temp").read_text()) / 1000
    except (OSError, ValueError):
        return None


def ved_kommando(emne: str, innhold: str) -> None:
    log.info("Kommando: %s = %s", emne, innhold)


def main() -> None:
    klient = Klient.fra_miljo()
    klient.ved_melding("kommando/#", ved_kommando)
    klient.start()

    def stopp(*_):
        klient.stopp()
        sys.exit(0)

    signal.signal(signal.SIGINT, stopp)
    signal.signal(signal.SIGTERM, stopp)

    log.info("%s starter (%s)", klient.enhet, klient.sted)
    while True:
        temp = cpu_temperatur()
        if temp is not None and klient.tilkoblet:
            klient.publiser("cpu-temperatur", round(temp, 1))
        time.sleep(MALEINTERVALL)


if __name__ == "__main__":
    main()
