# burpsuite.nix

Auto-updating [Nix](https://nixos.org/) flake for [Burp Suite](https://portswigger.net/burp).

This repository provides a Nix flake for Burp Suite Desktop that automatically updates to the latest available version.

### Run Burp Suite using Nix

```sh
nix run github:yechielw/burpsuite.nix
```


### As a Nix Flake Input

Add this repo as an input to your own flake:

flake.nix
```nix
{
  inputs.burpsuite.url = "github:yechielw/burpsuite.nix";
};
```
configuration.nix
```nix
{
  environment.systemPackages = [
    inputs.burpsuite.packages.${pkgs.system}.burpsuite
  ];
};
```

## Disclaimer
- **Not affiliated**: This project is not affiliated with PortSwigger or Burp Suite.

## Contributing

Contributions and suggestions are welcome! Please open issues or pull requests.
