{
  description = "bitwarden rofi client";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs?ref=nixos-25.11;
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
          rev = "f428ba51768bebc0388a17e77344b7daaee88d38";
          fetchSubmodules = true;
          sha256 = "sha256-9d87eha0Gw0+iVyx8JhvVIhgIqI6Iap6iA5+EfT0mX4=";
        };
      });
      default = bwmenu;
    });
  };
}
