{
  lib,
  stdenvNoCC,
  fetchurl,
  appimageTools,
  makeWrapper,
  writeShellApplication,
  curl,
  yq,
  common-updater-scripts,
}: let
  pname = "beepertexts";
  version = "4.0.551";
  src = fetchurl {
    url = "https://beeper-desktop.download.beeper.com/builds/Beeper-${version}.AppImage";
    hash = "sha256-OLwLjgWFOiBS5RkEpvhH7hreri8EF+JRvKy+Kdre8gM=";
  };
  appimage = appimageTools.wrapType2 {
    inherit version pname src;
    extraPkgs = pkgs: [pkgs.libsecret pkgs.gtk3];
  };
  appimageContents = appimageTools.extractType2 {
    inherit version pname src;
  };
in
  stdenvNoCC.mkDerivation rec {
    inherit pname version;

    src = appimage;

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/
      cp -r bin $out/bin

      mkdir -p $out/share/${pname}
      cp -a ${appimageContents}/locales $out/share/${pname}
      cp -a ${appimageContents}/resources $out/share/${pname}
      cp -a ${appimageContents}/usr/share/icons $out/share/
      install -Dm 644 ${appimageContents}/${pname}.desktop -t $out/share/applications/

      substituteInPlace $out/share/applications/${pname}.desktop --replace "AppRun" "${pname}"

      wrapProgram $out/bin/${pname} \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}} --no-update"

      runHook postInstall
    '';

    meta = with lib; {
      description = "The ultimate messaging app";
      longDescription = ''
        Beeper is a universal chat app. With Beeper, you can send
        and receive messages to friends, family and colleagues on
        many different chat networks.
      '';
      homepage = "https://beeper.com";
      license = licenses.unfree;
      platforms = ["x86_64-linux"];
    };
  }
