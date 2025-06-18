{
  description = "A simple LaTeX template for writing documents with latexmk";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        burp = pkgs.callPackage ./package.nix { };
      in
      {
        packages = {
          default = burp.pro;
          burpsuitepro = burp.pro;
          bupruite = burp.free;
        };

        nixosModules.burpsuite =
          { ... }:
          {
            # install pro into systemPackages
            environment.systemPackages = [ burp.pro ];

            # configure Nix to use your Cachix cache
            nix.settings = {
              substituters = [ "https://burpsuite.cachix.org/" ];
              trusted-public-keys = [ "burpsuite.cachix.org-1:9XNd5hio9NLn65G+c5duyV5j90RLUiZJItzhIwAYRu8=" ];
            };
          };
      }
    );
}
