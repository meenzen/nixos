{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.sudo-rs;
in {
  options.meenzen.sudo-rs = {
    enable = lib.mkEnableOption "Use sudo-rs instead of sudo";
  };

  config = lib.mkIf cfg.enable {
    # Replace sudo with sudo-rs to prevent memory vulnerabilities
    security.sudo.enable = false;
    security.sudo-rs.enable = true;
  };
}
