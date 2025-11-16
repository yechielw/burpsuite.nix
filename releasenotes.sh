#!/usr/bin/env nix-shell
#!nix-shell -i sh -p coreutils wget pup pandoc
set -eu -o pipefail

wget -k https://portswigger.net/burp/releases/professional-community-$(tr '.' '-' <<< "$VERSION") -O release.html
pup 'div#content' < release.html | pandoc --from=html --to=gfm --wrap=none -o release.md

