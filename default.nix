{
  stdenv,
  keyutils,
  jq,
  bitwarden-cli,
  git-rofi,
  xclip,
  gnupg,
  coreutils-full,
  buildPackages,
  lib,
  ...
}: let
  runtimePath = lib.strings.makeBinPath [
    jq
    bitwarden-cli
    git-rofi
    xclip
    keyutils
    gnupg
  ];
in
  stdenv.mkDerivation rec {
    name = "bw-rofi";
    src = ./.;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/lib
      mkdir -p $out/share/bwmenu
      substitute bwmenu $out/bin/bwmenu \
        --replace "source \"\$DIR/lib-bwmenu\"" "source \"$out/lib/lib-bwmenu\"" \
        --replace "THEMES_DIRECTORY=\$DIR/default_themes" "THEMES_DIRECTORY=$out/share/bwmenu/themes"
      ${coreutils-full}/bin/chmod +x $out/bin/bwmenu
      cp lib-bwmenu $out/lib
      cp -r default_themes $out/share/bwmenu/themes

      wrapProgram "$out/bin/bwmenu" \
          --prefix PATH : ${runtimePath}
    '';
    nativeBuildInputs = [buildPackages.makeWrapper];
  }
