#!/usr/bin/env nix-shell
#!nix-shell -i sh -p curl jq xxd coreutils
set -eu -o pipefail
# curl -s 'https://portswigger.net/burp/releases/data?pageSize=5' | jq -r '[[.ResultSet.Results[] | select ((.categories | sort) == (["Professional", "Community"] | sort) and .releaseChannels == ["Early Adopter"])][0].builds[] | select (.ProductPlatform == "Jar")]' > latest.json
# echo sha265-$(cat latest.json | jq '.[] | select ( .ProductId == "community") .Sha256Checksum' -r | xxd -r -p | base64)
# echo sha265-$(cat latest.json | jq '.[] | select ( .ProductId == "pro") .Sha256Checksum' -r | xxd -r -p | base64)
# cat latest.json | jq '.[0].Version' -r


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

