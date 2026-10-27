#!/bin/sh
# Bump the plugin version and build koha-plugin-tamil-matomo-<version>.kpz
# Usage: ./release.sh [version]   (default: increment the last number)
set -e
cd "$(dirname "$0")"

pm=Koha/Plugin/Tamil/Matomo.pm
old=$(perl -ne "print \$1 if /^\s*version\s*=>\s*'([^']+)'/" $pm)
new=${1:-$(echo "$old" | awk -F. -v OFS=. '{ $NF++; print }')}
echo "$new" | grep -Eq '^[0-9]+(\.[0-9]+)*$' || { echo "Invalid version: $new" >&2; exit 1; }

perl -pi -e "s/^(\s*version\s*=>\s*')[^']+/\${1}$new/; s/^(\s*date_updated\s*=>\s*\")[^\"]+/\${1}$(date +%F)/; s/^(\s*copyright\s*=>\s*')[^']+/\${1}$(date +%Y)/" $pm
perl -pi -e "s/koha-plugin-tamil-matomo-[\d.]+\d\.kpz/koha-plugin-tamil-matomo-$new.kpz/g" README.md
./readme.sh

kpz=koha-plugin-tamil-matomo-$new.kpz
rm -f "$kpz"
zip -qr "$kpz" Koha -x '*.DS_Store'
unzip -p "$kpz" $pm | grep -q "'$new'" || { echo "Version check failed in $kpz" >&2; exit 1; }
echo "$old -> $new: $kpz"
