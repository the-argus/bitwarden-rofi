{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs?ref=nixos-22.11;
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
      rofi = pkgs.${system}.rofi.overrideAttrs (_: {
        src = pkgs.${system}.fetchgit {
          url = "https://github.com/davatorium/rofi";
          rev = "23de9e9d2c35af8cce72b060f6d2916cd6215a23";
          sha256 = "sha256-pVZPMymXHOh3kmkiigkRRLmYaGk0o706P8PYja/+zMo=";
        };
      });
      default = bwmenu;
    });
  };
}
