{
  description = "Cross-platform Leapp installer via Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [
      "aarch64-darwin"
    ] (system:
      let
        appName = "Leapp.app";
        pname = "leapp";
        pkgs = import nixpkgs { inherit system; };

        leapp = let
          # Determine the correct binary based on platform
          platformInfo = {
            "aarch64-darwin" = {
              sha256 = "sha256-c/+gMN1ZKT92O9kDj192B0KbxQyCbevk5i1TnZyM0iw=";
              url = "https://asset.noovolari.com/latest/Leapp-0.26.1-mac-arm64.zip";
              filename = "Leapp.dmg";
            };
          }.${system};

        in pkgs.stdenv.mkDerivation {
          pname = "leapp";
          appName = "Leapp.app";
          version = "0.26.1";

          src = pkgs.fetchurl {
            url = platformInfo.url;
            sha256 = platformInfo.sha256;
          };

          nativeBuildInputs = with pkgs; [
            unzip
            hfsprogs
            dmg2img
          ];

          unpackPhase = ''
            unzip $src
            dmg2img Leapp-0.26.1-arm64.dmg Leapp.img
            mkdir -p mnt
            hdiutil attach -imagekey diskimage-class=CRawDiskImage -mountpoint mnt Leapp.img
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/Applications
            cp -R mnt/${appName} $out/Applications/
            hdiutil detach mnt
            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Leapp - The Cloud Access App";
            homepage = "https://www.leapp.cloud/";
            license = licenses.unfree;
            platforms = [ "aarch64-darwin" ];
            maintainers = [ ];
          };
        };

      in {
        packages.default = leapp;
        packages.leapp = leapp;
      });
}
