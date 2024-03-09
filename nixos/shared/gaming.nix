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
