#!/usr/bin/env bash
# Oppretter et nytt prosjekt fra malen i prosjekter/_mal
# Bruk: verktoy/nytt-prosjekt.sh <plattform> "Prosjektnavn"
#   verktoy/nytt-prosjekt.sh esp32 "Værstasjon ute"
#   -> prosjekter/esp32/ÅÅÅÅ-MM-vaerstasjon-ute/
set -euo pipefail

rot="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mal="$rot/prosjekter/_mal"

# Plattformer = alle mapper i prosjekter/ unntatt _mal
plattformer=()
for d in "$rot"/prosjekter/*/; do
    p="$(basename "$d")"
    [[ "$p" == _* ]] || plattformer+=("$p")
done

if [[ $# -ne 2 || -z "$2" ]]; then
    echo "Bruk: $0 <plattform> \"Prosjektnavn\"" >&2
    echo "Plattformer: ${plattformer[*]}" >&2
    exit 1
fi

plattform="$1"
navn="$2"

if [[ ! " ${plattformer[*]} " == *" $plattform "* ]]; then
    echo "Ukjent plattform: $plattform" >&2
    echo "Plattformer: ${plattformer[*]}" >&2
    exit 1
fi

# Lag et filnavnvennlig navn: små bokstaver, ae/o/a i stedet for æ/ø/å, bindestrek
slug="${navn,,}"
slug="${slug//æ/ae}"
slug="${slug//ø/o}"
slug="${slug//å/a}"
slug="$(printf '%s' "$slug" | LC_ALL=C sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"

if [[ -z "$slug" ]]; then
    echo "Navnet «$navn» gir et tomt mappenavn." >&2
    exit 1
fi

mappe="$rot/prosjekter/$plattform/$(date +%Y-%m)-$slug"

if [[ -e "$mappe" ]]; then
    echo "Prosjektet finnes allerede: $mappe" >&2
    exit 1
fi

cp -r "$mal" "$mappe"

# Plattformen kan ha maler for undermapper: prosjekter/<plattform>/_<mappe>-mal
# kopieres til <prosjekt>/<mappe>/ (f.eks. _firmware-mal -> firmware/, _pi-mal -> pi/)
for undermal in "$rot/prosjekter/$plattform"/_*-mal; do
    [[ -d "$undermal" ]] || continue
    undermappe="$(basename "$undermal")"
    undermappe="${undermappe#_}"
    undermappe="${undermappe%-mal}"
    mkdir -p "$mappe/$undermappe"
    cp -rL "$undermal/." "$mappe/$undermappe/"
done

# Lag ekte hemmelighetsfiler fra eksemplene, så prosjektet kan kjøres med en gang (gitignored).
# Verdier fylles inn fra de lokale passordfilene hvis de finnes.
hent() {  # hent NØKKEL fil
    [[ -r "$2" ]] && grep -m1 "^$1=" "$2" | cut -d= -f2- || true
}
declare -A verdi=(
    [WIFI_SSID]="$(hent WIFI_SSID "$rot/verktoy/sd-kort.env")"
    [WIFI_PASSORD]="$(hent WIFI_PASSORD "$rot/verktoy/sd-kort.env")"
    [MQTT_BRUKER]="$(hent MQTT_BRUKER "$rot/infrastruktur/.env")"
    [MQTT_PASSORD]="$(hent MQTT_PASSORD "$rot/infrastruktur/.env")"
    [OTA_PASSORD]="$(hent OTA_PASSORD "$rot/infrastruktur/.env")"
)
c_streng() { local s="${1//\\/\\\\}"; printf '%s' "${s//\"/\\\"}"; }

while IFS= read -r -d '' eks; do
    ekte="${eks/.example/}"
    [[ -e "$ekte" ]] && continue
    cp "$eks" "$ekte"
    for n in "${!verdi[@]}"; do
        v="${verdi[$n]}"
        [[ -n "$v" ]] || continue
        if [[ "$ekte" == *.h ]]; then
            # #define NAVN  ""  ->  #define NAVN  "verdi"
            python3 - "$ekte" "$n" "$(c_streng "$v")" <<'PY'
import re, sys
p, navn, verdi = sys.argv[1:]
s = open(p, encoding="utf-8").read()
s = re.sub(rf'^(#define {navn}\s+)""', lambda m: m.group(1) + '"' + verdi + '"', s, flags=re.M)
open(p, "w", encoding="utf-8").write(s)
PY
        else
            python3 - "$ekte" "$n" "$v" <<'PY'
import re, sys
p, navn, verdi = sys.argv[1:]
s = open(p, encoding="utf-8").read()
s = re.sub(rf'^{navn}=$', lambda m: f"{navn}={verdi}", s, flags=re.M)
open(p, "w", encoding="utf-8").write(s)
PY
        fi
    done
done < <(find "$mappe" \( -name 'secrets.example.*' -o -name '.env.example' \) -print0)

find "$mappe" -name .gitkeep -delete

# Escape tegn som har spesiell betydning i sed-erstatningen
navn_sed="$(printf '%s' "$navn" | sed 's/[&|\\]/\\&/g')"
sed -i -e "s|{{NAVN}}|$navn_sed|g" \
       -e "s|{{DATO}}|$(date +%Y-%m-%d)|g" \
       -e "s|{{PLATTFORM}}|$plattform|g" "$mappe/README.md"

echo "Opprettet: $mappe"
echo "Fyll ut README.md, særlig «Slik henger det sammen»."

for f in README.md verktoy.md; do
    if [[ ! -f "$rot/prosjekter/$plattform/$f" ]]; then
        echo "Advarsel: prosjekter/$plattform/$f mangler (standard for alle plattformer)." >&2
    fi
done
