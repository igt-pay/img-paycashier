#!/bin/bash
set -euo pipefail

: "${SharedService?Needs to be set}"

VER=''
IFS=' '
while read -ra line
do
    sufix="${line[1]/22.0./}"
    VER="${VER}_${line[0]}_${sufix}"
done <<< "$(cat "Latest/paycashier-${SharedService}.versions")"

echo "${VER/\_/}"