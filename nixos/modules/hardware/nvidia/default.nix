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
    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    hardware.graphics = {
      # On 64-bit systems, whether to also install 32-bit drivers for 32-bit applications (such as Wine).
      enable32Bit = true;
      extraPackages = with pkgs; [
        # Video acceleration support
        nvidia-vaapi-driver
      ];
    };
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";

      # required for Firefox
      MOZ_DISABLE_RDD_SANDBOX = "1";
    };
    environment.systemPackages = with pkgs; [
      libva
      libva-utils
    ];

    # Use lts kernel, latest is broken
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_6;
  };
}
