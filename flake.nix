{
  description = "burpsuite flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      systems = flake-utils.lib.systems;
    in
    flake-utils.lib.eachDefaultSystem systems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        burp = pkgs.callPackage ./package.nix { };
      in
      {
        packages = {
          default = burp.pro;
          burpsuitepro = burp.pro;
          burpsuitecommunity = burp.community;
        };

        nixosModules.burpsuite =
          {...}:
          {
            environment.systemPackages = [ burp.pro ];
            nix.settings = {
              substituters = [ "https://burpsuite.cachix.org/" ];
              trusted-public-keys = [
                "burpsuite.cachix.org-1:9XNd5hio9NLn65G+c5duyV5j90RLUiZJItzhIwAYRu8="
              ];
            };
          };
      }
    )
    // {
      # expose a top-level module for easy import
      nixosModule = self.${builtins.currentSystem}.nixosModules.burpsuite;
    };
}
