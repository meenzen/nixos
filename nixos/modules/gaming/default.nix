{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # https://github.com/fufexan/nix-gaming
  imports = [
    inputs.nix-gaming.nixosModules.pipewireLowLatency
    inputs.protontweaks.nixosModules.protontweaks
  ];

  # https://github.com/rain-cafe/protontweakss
  nixpkgs = {
    overlays = [
      inputs.protontweaks.overlay
    ];
  };
  services.protontweaks.enable = true;

  # Gaming Kernel (unstable)
  # boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Low Latency Audio
  services.pipewire.lowLatency = {
    enable = true;
    quantum = 64;
    rate = 48000;
  };
  security.rtkit.enable = true; # make pipewire realtime-capable

  environment.systemPackages = [
    inputs.nix-citizen.packages.${pkgs.system}.star-citizen
    pkgs.heroic

    pkgs.wineWowPackages.stable
    pkgs.winetricks
    pkgs.mangohud
  ];

  programs.gamemode.enable = true;

  # NixOS configuration for Star Citizen requirements
  # https://github.com/fufexan/nix-gaming/tree/master/pkgs/star-citizen
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };
  networking.extraHosts = "127.0.0.1 modules-cdn.eac-prod.on.epicgames.com";

  # At least 40GB of ram is recommended for Star Citizen, so we need to enable zram
  zramSwap.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };

  # enable game tweaks by adjusting the game launch options:
  # `gamemoderun %command%`
  # `mangohud %command%`
  # `gamescope %command%`
}
