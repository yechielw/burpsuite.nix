{
  description = "Auto updating flake for Burp Suite";

  nixConfig = {
    substituters = [ "https://burpsuite.cachix.org/" ];
    trusted-public-keys = [ "burpsuite.cachix.org-1:9XNd5hio9NLn65G+c5duyV5j90RLUiZJItzhIwAYRu8=" ];
  };

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
    let
      eachSystem = flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          burpsuite = pkgs.callPackage ./package.nix { };
        in
        {
          packages = {
            default = burpsuite;
            inherit burpsuite;
            burpsuite-desktop = burpsuite;
          };
        }
      );
    in
    eachSystem;
}
