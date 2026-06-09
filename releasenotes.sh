#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash coreutils jq wget pup pandoc
set -euo pipefail

release_path=$(
  jq -r --arg version "$VERSION" '
    .ReleaseUrl // ("/burp/releases/professional-community-" + ($version | gsub("\\."; "-")))
  ' latest.json
)

case "$release_path" in
  https://*) release_url="$release_path" ;;
  /*) release_url="https://portswigger.net$release_path" ;;
  *) release_url="https://portswigger.net/burp/releases/$release_path" ;;
esac

wget -k "$release_url" -O release.html
pup 'div#content' < release.html | pandoc --from=html --to=gfm --wrap=none -o release.md
cat >> release.md<< EOF
run this version
\`\`\`sh
nix run 'github:yechielw/burpsuite.nix?ref=$VERSION'
\`\`\`
EOF
