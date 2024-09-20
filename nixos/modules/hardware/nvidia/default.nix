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
    # Nvidia
    hardware.graphics.extraPackages = with pkgs; [vaapiVdpau];

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = ["nvidia"];
    boot.kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
      # workaround for 555 stutters
      "nvidia.NVreg_EnableGpuFirmware=0"
    ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };
}
