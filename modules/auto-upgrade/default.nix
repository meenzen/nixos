{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.auto-upgrade;
  hostname = config.networking.hostName;
in {
  options.meenzen.auto-upgrade = {
    enable = lib.mkEnableOption "Enable NixOS Auto Upgrade";
    boot = lib.mkEnableOption "Run 'nixos-rebuild boot' instead of 'nixos-rebuild switch'";
    allowReboot = lib.mkEnableOption "Allow automatic reboots after upgrade";
  };

  config = lib.mkIf cfg.enable {
    system.autoUpgrade = {
      # Don't auto-upgrade if running uncommitted changes. This prevents
      # accidental upgrades when testing changes.
      enable = (inputs.self.rev or "dirty") != "dirty";

      flake = "github:meenzen/nixos#${hostname}";

      # Don't try to update the lockfile, always use the pinned version.
      upgrade = false;

      # Run upgrade at noon every day. This is a good time as it probably won't interfere
      # with backups or other maintenance tasks.
      dates = "12:00";
      randomizedDelaySec = "45min";

      operation =
        if cfg.boot
        then "boot"
        else "switch";

      allowReboot = cfg.allowReboot;
    };
  };
}
