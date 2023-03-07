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
  xdotool,
  autoLock ? 900,
  waylandSupport ? false,
  ydotool,
  wl-clipboard,
  ...
}: let
  deps =
    [
      jq
      bitwarden-cli
      git-rofi
      xclip
      keyutils
      gnupg
      xdotool
    ]
    ++ (lib.lists.optionals waylandSupport [
      ydotool
      wl-clipboard
    ]);
  runtimePath = lib.strings.makeBinPath deps;
in
  stdenv.mkDerivation rec {
    name = "bwmenu";
    src = ./.;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/bwmenu
      substitute bwmenu $out/bin/bwmenu \
        --replace "source \"\$DIR/lib-bwmenu\"" "source \"$out/share/bwmenu/lib\"" \
        --replace "THEMES_DIRECTORY=\$DIR/default_themes" "THEMES_DIRECTORY=$out/share/bwmenu/themes" \
        --replace "AUTO_LOCK=900" "AUTO_LOCK=${builtins.toString autoLock}" \
        --replace "AUTOTYPE_MODE=\"UNSET\"" "AUTOTYPE_MODE=\"xdotool\""
      ${coreutils-full}/bin/chmod +x $out/bin/bwmenu
      cp lib-bwmenu $out/share/bwmenu/lib
      cp -r default_themes $out/share/bwmenu/themes
      cp -r icon $out/share/bwmenu/themes/icon

      substitute default_themes/common.rasi $out/share/bwmenu/themes/common.rasi \
        --replace "icon {background-image: url(\"~/.config/bwmenu/icon/bitwarden.png\", height);}" \
        "icon {background-image: url(\"$out/share/bwmenu/themes/icon/bitwarden.png\", height);}"

      substitute default_themes/main_theme.rasi $out/share/bwmenu/themes/main_theme.rasi \
        --replace "icon {background-image: url(\"~/.config/bwmenu/icon/bitwarden-border.png\", height);}" \
        "icon {background-image: url(\"$out/share/bwmenu/themes/icon/bitwarden-border.png\", height);}"

      wrapProgram "$out/bin/bwmenu" \
          --prefix PATH : ${runtimePath}
    '';
    nativeBuildInputs = [buildPackages.makeWrapper] ++ deps;
  }
