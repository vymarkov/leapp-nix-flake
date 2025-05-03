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
            "x86_64-linux" = {
              url = "https://github.com/Noovolari/leapp/releases/latest/download/Leapp-x86_64.AppImage";
              sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
              filename = "Leapp.AppImage";
            };
            "aarch64-linux" = {
              url = "https://github.com/Noovolari/leapp/releases/latest/download/Leapp-aarch64.AppImage";
              sha256 = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
              filename = "Leapp.AppImage";
            };
            "x86_64-darwin" = {
              url = "https://github.com/Noovolari/leapp/releases/latest/download/Leapp.dmg";
              sha256 = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=";
              filename = "Leapp.dmg";
            };
            "aarch64-darwin" = {
              sha256 = "sha256-c/+gMN1ZKT92O9kDj192B0KbxQyCbevk5i1TnZyM0iw=";
              url = "https://asset.noovolari.com/latest/Leapp-0.26.1-mac-arm64.zip";
              filename = "Leapp.dmg";
            };
          }.${system};

        in pkgs.stdenv.mkDerivation {
          pname = "leapp";
          appName = "Leapp.app";
          version = "latest";

          src = pkgs.fetchurl {
            url = platformInfo.url;
            sha256 = platformInfo.sha256;
          };

          # nativeBuildInputs = pkgs.lib.optional pkgs.stdenv.isDarwin pkgs.hfsprogs pkgs.unzip;

          nativeBuildInputs = [ pkgs.unzip ];

          unpackPhase = ''
            unzip $src -d extracted
            export sourceRoot=$PWD/extracted
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/{Applications/${appName},bin}
            cp -R $sourceRoot/release/Leapp-0.26.1-arm64.dmg $out/Applications/${appName}
            runHook postInstall
          '';

        };

      in {
        packages.default = leapp;
        packages.leapp = leapp;
      });
}
