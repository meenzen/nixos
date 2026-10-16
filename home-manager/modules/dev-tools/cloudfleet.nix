{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
}:
stdenv.mkDerivation rec {
  pname = "cloudfleet";
  version = "0.6.3";

  src = fetchzip {
    url = "https://downloads.cloudfleet.ai/cli/${version}/cloudfleet_linux_amd64.zip";
    hash = "sha256-ZUiX5qm2Tktleaqosxo4k4OK6975QBfQ02NzgG+qPaU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall
    install -m755 -D cloudfleet $out/bin/cloudfleet
    runHook postInstall
  '';

  meta = {
    homepage = "https://cloudfleet.ai/";
    description = "Cloudfleet CLI";
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}
