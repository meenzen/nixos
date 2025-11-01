{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.winboat;
in {
  options.meenzen.winboat = {
    enable = lib.mkEnableOption "Enable WinBoat";
  };

  # Adapted from https://github.com/Simon-Weij/winboat/commit/b4862793912a2a0cfa517c4f3782bc8e2e9c7037#diff-206b9ce276ab5971a2489d75eb1b12999d4bf3843b7988cbe8d687cfde61dea0R205-R220
  config = lib.mkIf cfg.enable {
    # Ensure required services are enabled
    virtualisation.docker.enable = true;
    virtualisation.libvirtd.enable = true;

    # Load required kernel modules
    boot.kernelModules = ["iptable_nat"];

    # Install WinBoat and dependencies
    environment.systemPackages = with pkgs; [
      winboat
      freerdp
      docker-compose
      iptables
    ];
  };
}
