#!/usr/bin/env bash
# Oppretter et nytt prosjekt fra malen i prosjekter/_mal
# Bruk: verktoy/nytt-prosjekt.sh "Værstasjon ute"
#   -> prosjekter/ÅÅÅÅ-MM-vaerstasjon-ute/
set -euo pipefail

if [[ $# -ne 1 || -z "$1" ]]; then
    echo "Bruk: $0 \"Prosjektnavn\"" >&2
    exit 1
fi

navn="$1"
rot="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mal="$rot/prosjekter/_mal"

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

mappe="$rot/prosjekter/$(date +%Y-%m)-$slug"

if [[ -e "$mappe" ]]; then
    echo "Prosjektet finnes allerede: $mappe" >&2
    exit 1
fi

cp -r "$mal" "$mappe"
find "$mappe" -name .gitkeep -delete

# Escape tegn som har spesiell betydning i sed-erstatningen
navn_sed="$(printf '%s' "$navn" | sed 's/[&|\\]/\\&/g')"
sed -i -e "s|{{NAVN}}|$navn_sed|g" -e "s|{{DATO}}|$(date +%Y-%m-%d)|g" "$mappe/README.md"

echo "Opprettet: $mappe"
