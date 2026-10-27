#!/bin/sh
# Render README.md to HTML in home-readme.tt, included by home.tt
set -e
cd "$(dirname "$0")"
pandoc -f gfm -t html README.md -o Koha/Plugin/Tamil/Matomo/home-readme.tt
