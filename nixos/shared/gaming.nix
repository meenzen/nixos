{ inputs, lib, config, pkgs, ... }:
{
  # https://github.com/fufexan/nix-gaming
  imports = [
    inputs.nix-gaming.nixosModules.pipewireLowLatency
    inputs.nix-gaming.nixosModules.steamCompat
  ];

  # Gaming Kernel
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Low Latency
  services.pipewire.lowLatency = {
    enable = true;
    quantum = 64;
    rate = 48000;
  };
  security.rtkit.enable = true; # make pipewire realtime-capable

  environment.systemPackages = [
    inputs.nix-gaming.packages.${pkgs.system}.star-citizen
  ];

  # NixOS configuration for Star Citizen requirements
  # https://github.com/fufexan/nix-gaming/tree/master/pkgs/star-citizen
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };
  networking.extraHosts = "127.0.0.1 modules-cdn.eac-prod.on.epicgames.com";

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    # add extra compatibility tools to your STEAM_EXTRA_COMPAT_TOOLS_PATHS using the newly added `extraCompatPackages` option
    extraCompatPackages = [
      # add the packages that you would like to have in Steam's extra compatibility packages list
      # pkgs.luxtorpeda
      inputs.nix-gaming.packages.${pkgs.system}.proton-ge
    ];
  };
}
