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
  deps = [
    jq
    bitwarden-cli
    git-rofi
    xclip
    keyutils
    gnupg
  ];
  runtimePath = lib.strings.makeBinPath deps;
in
  stdenv.mkDerivation rec {
    name = "bw-rofi";
    src = ./.;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/bwmenu
      substitute bwmenu $out/bin/bwmenu \
        --replace "source \"\$DIR/lib-bwmenu\"" "source \"$out/share/bwmenu/lib\"" \
        --replace "THEMES_DIRECTORY=\$DIR/default_themes" "THEMES_DIRECTORY=$out/share/bwmenu/themes"
      ${coreutils-full}/bin/chmod +x $out/bin/bwmenu
      cp lib-bwmenu $out/share/bwmenu/lib
      cp -r default_themes $out/share/bwmenu/themes
      cp -r icon $out/share/bwmenu/themes/icon

      wrapProgram "$out/bin/bwmenu" \
          --prefix PATH : ${runtimePath}
    '';
    nativeBuildInputs = [buildPackages.makeWrapper] ++ deps;
  }
