{
  description = "bitwarden rofi client";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs?ref=nixos-unstable;
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    genSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs = genSystems (system: import nixpkgs {inherit system;});
  in {
    packages = genSystems (system: rec {
      bwmenu = pkgs.${system}.callPackage ./. {git-rofi = rofi;};
      rofi = pkgs.${system}.rofi.override {inherit rofi-unwrapped;};
      rofi-unwrapped = pkgs.${system}.rofi-unwrapped.overrideAttrs (_: {
        src = pkgs.${system}.fetchFromGitHub {
          owner = "davatorium";
          repo = "rofi";
          rev = "23de9e9d2c35af8cce72b060f6d2916cd6215a23";
          fetchSubmodules = true;
          sha256 = "sha256-pVZPMymXHOh3kmkiigkRRLmYaGk0o706P8PYja/+zMo=";
        };
      });
      default = bwmenu;
    });
  };
}
