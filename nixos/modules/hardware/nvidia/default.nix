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
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };

    # Video acceleration support
    hardware.graphics.extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      nvidia-vaapi-driver
    ];
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
    };

    # On 64-bit systems, whether to also install 32-bit drivers for 32-bit applications (such as Wine).
    hardware.graphics.enable32Bit = true;

    # Temporary workaround for https://github.com/NixOS/nixpkgs/issues/344167
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_10;
  };
}
