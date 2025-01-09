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
    inputs.protontweaks.nixosModules.protontweaks
    ./star-citizen.nix
  ];

  config = lib.mkIf cfg.enable {
    meenzen.gaming.star-citizen.enable = lib.mkDefault true;

    nix.settings = {
      substituters = ["https://nix-gaming.cachix.org"];
      trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
    };

    # https://github.com/rain-cafe/protontweaks
    nixpkgs.overlays = [inputs.protontweaks.overlay];
    services.protontweaks.enable = true;

    # Kernel Tweaks
    # boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
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
      pkgs.wineWowPackages.stable
      pkgs.winetricks
      pkgs.mangohud
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
    };

    # xbox controller driver
    hardware.xone.enable = true;

    programs.gamemode.enable = true;
    # enable game tweaks by adjusting the game launch options:
    # `gamemoderun %command%`
    # `mangohud %command%`
    # `gamescope %command%`
  };
}
