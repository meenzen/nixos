{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.hardware.nvidia;
in {
  options.custom.hardware.nvidia = {
    enable = lib.mkEnableOption "Enable Nvidia GPU support";
  };

  config = lib.mkIf cfg.enable {
    # Video acceleration
    hardware.graphics.extraPackages = with pkgs; [vaapiVdpau];

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };

    # Temporary workaround for https://github.com/NixOS/nixpkgs/issues/344167
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_10;
  };
}
