#!/usr/bin/env nix-shell
#!nix-shell -i sh -p curl jq xxd coreutils wget pup pandoc
set -eu -o pipefail

curl -s 'https://portswigger.net/burp/releases/data?pageSize=50' | jq -r '
      def verarr: (.Version // "") | split(".") | map(tonumber? // 0);
      def jar_builds:
        .builds[]
        | select((.BuildCategoryPlatform // .ProductPlatform) == "Jar");
      def desktop_as($id; $edition):
        . + {
          BuildCategoryId: $id,
          BuildCategoryEdition: $edition,
          DownloadBuildCategoryId: "desktop"
        };

      [ .ResultSet.Results[]
        | select(
            ((.categories | sort) == (["Professional", "Community"] | sort))
            or (((.categories | sort) == ["Desktop"]) and (.url | startswith("/burp/releases/professional-community-")))
          )
      ] as $releases
      | ($releases | max_by(.version | split(".") | map(tonumber? // 0))) as $latest
      | if (($latest.categories | sort) == ["Desktop"]) then
          ($latest | jar_builds) as $jar
          | [
              ($jar | desktop_as("community"; "Burp Suite Community Edition")),
              ($jar | desktop_as("pro"; "Burp Suite Professional"))
            ]
        else
          [ $latest | jar_builds ]
        end
    ' > latest.json
