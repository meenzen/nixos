{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.hardware.nvidia;
in {
  options.meenzen.hardware.nvidia = {
    enable = lib.mkEnableOption "Nvidia GPU support";
  };

  config = lib.mkIf cfg.enable {
    # Load nvidia driver (option name is X11-specific, but also enables the kernel driver for Wayland)
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
      extraPackages = [
        # Video acceleration support
        pkgs.nvidia-vaapi-driver
      ];
    };
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";

      # required for Firefox
      MOZ_DISABLE_RDD_SANDBOX = "1";
    };
    environment.systemPackages = [
      pkgs.libva
      pkgs.libva-utils
    ];

    nixpkgs.overlays = [
      (_: prev: {
        gamescope = prev.gamescope.overrideAttrs (old: {
          patches =
            (old.patches or [])
            ++ [
              # Fixes artifacting on NVIDIA by forcing contiguous scanout allocations via GBM
              # https://github.com/antheas/gamescope/commit/fa6f7f2503c2e773acf818ad688ddd1db73df3a0
              ./gamescope-nvidia-scanout.patch
            ];
        });
      })
    ];
  };
}
