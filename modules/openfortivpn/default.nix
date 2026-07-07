{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.openfortivpn;
  # Update request: https://github.com/NixOS/nixpkgs/issues/539205
  openfortivpn-webview-qt = pkgs.openfortivpn-webview-qt.overrideAttrs (_: rec {
    version = "1.3.0";
    src = pkgs.fetchFromGitHub {
      owner = "gm-vm";
      repo = "openfortivpn-webview";
      rev = "v${version}-qt";
      hash = "sha256-TohrOgLzvxmUsRVV36XHgE9ul38CjU/qKF+LZOZQieE=";
    };
    sourceRoot = "${src.name}/openfortivpn-webview-qt";
    nativeBuildInputs = [
      pkgs.qt6Packages.wrapQtAppsHook
      pkgs.cmake
      pkgs.ninja
    ];
    buildInputs = [
      pkgs.qt6Packages.qtbase
      pkgs.qt6Packages.qtwebengine
    ];
    patches = [
      ./pin-dialog.patch
    ];
  });
in {
  options.meenzen.openfortivpn = {
    enable = lib.mkEnableOption "Enable Fortinet VPN support";
    host = lib.mkOption {
      type = lib.types.str;
      default = "vpn.human.de";
      description = "The Fortinet VPN host to connect to.";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 443;
      description = "The Fortinet VPN port to connect to.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.openfortivpn
      openfortivpn-webview-qt
      (
        pkgs.writeShellApplication
        {
          name = "human-vpn";
          text = ''
            # cache credentials so the next command doesn't ask for the password again
            sudo -v

            openfortivpn-webview "${cfg.host}:${toString cfg.port}" 2>/dev/null \
            | sudo openfortivpn "${cfg.host}:${toString cfg.port}" --cookie-on-stdin --pppd-accept-remote
          '';
        }
      )
    ];
  };
}
