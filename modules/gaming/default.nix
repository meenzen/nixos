{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.gaming;
in {
  options.meenzen.gaming = {
    enable = lib.mkEnableOption "Enable everything required for gaming";
  };

  imports = [
    # https://github.com/fufexan/nix-gaming
    inputs.nix-gaming.nixosModules.pipewireLowLatency
    ./jovian.nix
    ./star-citizen.nix
  ];

  config = lib.mkIf cfg.enable {
    meenzen.gaming.star-citizen.enable = lib.mkDefault true;

    nix.settings = {
      substituters = ["https://nix-gaming.cachix.org"];
      trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
    };

    # Kernel Tweaks
    boot.kernel.sysctl = {
      "vm.max_map_count" = 16777216;
      "fs.file-max" = 524288;
    };
    zramSwap.enable = true;

    # Low Latency Audio
    services.pipewire.lowLatency = {
      enable = true;
      quantum = 64;
      rate = 48000;
    };
    security.rtkit.enable = true; # make pipewire realtime-capable

    environment.systemPackages = [
      pkgs.heroic
      pkgs.wineWow64Packages.stable
      pkgs.mangohud
    ];

    environment.variables = {
      DXVK_HUD = "compiler";
    };

    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        extraEnv = {
          OBS_VKCAPTURE = true;
          DXVK_HUD = "compiler";

          # These must not be set because they interfere with some games.
          # They are set system-wide for software development, so we need
          # to override them here.
          DOTNET_ROOT = lib.mkForce "";
          DOTNET_ROOT_X64 = lib.mkForce "";
          DOTNET_MULTILEVEL_LOOKUP = lib.mkForce "";
        };
      };
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
    };

    # xbox controller driver
    hardware.xone.enable = true;
  };
}
