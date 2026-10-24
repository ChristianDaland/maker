# Elektronikk og sikkerhet

## Strøm

- Motorer skal ha **egen strømforsyning**. Ikke driv motorer fra 5V-pinnen på Pi-en, fra ESP32-kortet eller fra USB-porten på PC-en. Strømtrekket og støyen fra motorer kan få Pi-en til å starte på nytt, og i verste fall skade utstyr – også USB-porten på EliteBooken.
- Koble **felles jord (GND)** mellom motorforsyningen og mikrokontrolleren, ellers blir styresignalene upålitelige.
- Bruk en **USB-hub med egen strømforsyning** når flere kort er koblet til PC-en samtidig.
- Raspberry Pi trenger en ordentlig strømforsyning (5 V, 3 A for Pi 4, 5 A for Pi 5). Lyn-symbol eller `undervoltage` i `dmesg` betyr for svak forsyning.

## Spenningsnivåer

- ESP32 og Raspberry Pi bruker **3,3 V logikk**. 5 V direkte inn på en GPIO-pinne kan ødelegge brikken. Bruk nivåomformer eller spenningsdeler mot 5 V-sensorer.
- En GPIO-pinne tåler bare noen få milliampere. Bruk transistor, MOSFET eller relémodul for alt som trekker mer enn en LED.
- Sjekk alltid databladet før du kobler en ny komponent. Legg databladet i `komponenter/datablad/`.

## Motorer og motordrivere

- DC-motorer og steppere styres via en motordriver, aldri direkte fra en GPIO-pinne. Motoren trekker langt mer strøm enn pinnen tåler, og gir spenningstopper når den stopper.
- Vanlige drivere: TB6612FNG (små DC-motorer, effektiv), L298N (gammel og varm, men robust), DRV8825 / A4988 / TMC2209 (steppere, still inn strømgrensen).
- Servoer trenger stabil 5 V-forsyning med nok strøm; noen hundre mA per servo under last.
- En kondensator (f.eks. 100–470 µF) over motorforsyningen demper spenningsfall.

## Batterier (Li-ion og LiPo)

- Litiumbatterier skal lades med riktig lader og beskyttelseskrets (f.eks. TP4056-modul med beskyttelse for én celle).
- Ikke utlad under ca. 3,0 V per celle, og ikke lad over 4,2 V.
- Kortslutning av et litiumbatteri kan gi brann. Isoler løse ledninger, og bruk sikring på større pakker.
- Skadede eller oppsvulmede batterier skal ikke brukes; lever dem som farlig avfall.
- Ikke la LiPo-lading stå uten tilsyn, og lad gjerne i en brannsikker pose.

## Gode vaner

- Koble fra strømmen før du endrer koblinger.
- Mål med multimeter før du kobler til noe nytt, særlig spenning og polaritet.
- Sjekk koblingen to ganger før du slår på: VCC og GND bytt om er den vanligste feilen.
- Ta et bilde av koblingen når noe fungerer, og legg det i prosjektets `hardware/`-mappe.
