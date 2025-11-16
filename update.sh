#!/usr/bin/env nix-shell
#!nix-shell -i sh -p curl jq xxd coreutils wget pup pandoc
set -eu -o pipefail

curl -s 'https://portswigger.net/burp/releases/data?pageSize=5' | jq -r '
      def verarr: (.Version // "") | split(".") | map(tonumber? // 0);
      [ .ResultSet.Results[]
        | select((.categories|sort) == (["Professional","Community"]|sort))
        | .builds[]
        | select(.ProductPlatform == "Jar")
      ] as $all
      | ($all | max_by( (.Version // "") | split(".") | map(tonumber? // 0) ) | .Version) as $v
      | $all | map(select(.Version == $v))
    ' > latest.json
