#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash coreutils curl jq
set -euo pipefail

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

curl -fsSL 'https://portswigger.net/burp/releases/data?pageSize=50' | jq -r '
      def jar_builds:
        .builds[]
        | select((.BuildCategoryPlatform // .ProductPlatform) == "Jar");

      [ .ResultSet.Results[]
        | select(
            ((.categories | sort) == ["Desktop"])
            and (.url | startswith("/burp/releases/professional-community-"))
          )
      ] as $releases
      | ($releases | max_by(.version | split(".") | map(tonumber? // 0))) as $latest
      | ($latest | jar_builds)
      | . + {
          ReleaseUrl: $latest.url,
          ReleaseTitle: $latest.title
        }
    ' > "$tmp"

mv "$tmp" latest.json
trap - EXIT
