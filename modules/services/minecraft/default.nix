{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.minecraft;
in {
  options.meenzen.services.minecraft = {
    enable = lib.mkEnableOption "Enable Minecraft";
  };

  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
    {
      nixpkgs.overlays = [inputs.nix-minecraft.overlay];
    }
    ./flip.nix
  ];

  config = lib.mkIf cfg.enable {
    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
    };
    meenzen.backup.paths = ["/srv/minecraft"];
  };
}
