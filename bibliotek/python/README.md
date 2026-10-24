# Felles Python-kode

Python-pakken `maker`, som Pi- og PC-prosjektene deler.

| Modul | Innhold |
|---|---|
| [`maker/mqtt.py`](maker/mqtt.py) | MQTT-klient med verkstedets konvensjoner: emner `maker/<sted>/<enhet>/<navn>`, `online`/`offline`-status, automatisk ny tilkobling. Tilsvarer `maker_nett` på ESP32 |

Python-malen (`prosjekter/raspberry-pi/_pi-mal/`) finner pakken automatisk via stien til `~/maker/bibliotek/python`, så den trenger ikke installeres. Avhengigheter (`paho-mqtt`) står i prosjektets `requirements.txt`.
