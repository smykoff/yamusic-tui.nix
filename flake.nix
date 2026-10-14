{
  description = "Yandex Music terminal client for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      # Upstream only publishes linux-amd64 and windows-amd64 builds.
      systems = [ "x86_64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});
    in {
      packages = forAll (pkgs: {
        default = pkgs.callPackage ./package.nix { };
      });

      overlays.default = final: prev: {
        yamusic-tui = final.callPackage ./package.nix { };
      };
    };
}
