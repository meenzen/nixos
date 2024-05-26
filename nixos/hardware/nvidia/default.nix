{
  pkgs,
  config,
  lib,
  ...
}: {
  # Nvidia OpenGL
  hardware.opengl.extraPackages = with pkgs; [vaapiVdpau];

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  boot.kernelParams = ["nvidia-drm.modeset=1" "nvidia-drm.fbdev=1"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    #package = config.boot.kernelPackages.nvidiaPackages.latest;
    package = config.boot.kernelPackages.nvidiaPackages.beta; # 555 beta (explicit sync for proper wayland support)
  };
}
