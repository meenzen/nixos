{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.minecraft;
in {
  options.meenzen.minecraft = {
    enable = lib.mkEnableOption "Enable Minecraft server";
    voiceChatPort = lib.mkOption {
      type = lib.types.int;
      default = 24454;
      description = ''
        The port for the Simple Voice Chat server.
      '';
    };
  };

  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
    {
      nixpkgs.overlays = [inputs.nix-minecraft.overlay];
    }
  ];

  config = lib.mkIf cfg.enable {
    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
      servers.flip = let
        modpack = pkgs.fetchPackwizModpack {
          url = "https://forge.mnzn.dev/FLiP/minecraft-modpack/raw/commit/1829cfafadea57e943d53374469bc5afdf0f61c7/pack.toml";
          packHash = "sha256-byqmMZNzEUOrJXyhD8uKqNv6PF2rDOv03O8OQl9+22g=";
          manifestHash = "sha256:0cxadv9k7v7csxf7p3pv5ycpszh975ailla1ig827gg96a7j15lw";
        };
        mcVersion = modpack.manifest.versions.minecraft;
        fabricVersion = modpack.manifest.versions.fabric;
        serverVersion = lib.replaceStrings ["."] ["_"] "fabric-${mcVersion}";
      in {
        enable = true;
        jvmOpts = "-Xmx8G -Xms2G";
        package = pkgs.fabricServers.${serverVersion}.override {loaderVersion = fabricVersion;};
        symlinks = {
          "mods" = "${modpack}/mods";
        };
      };
    };
    networking.firewall.allowedUDPPorts = [
      cfg.voiceChatPort
    ];
    environment.systemPackages = [
      pkgs.tmux
      (
        pkgs.writeShellApplication {
          name = "minecraft-console-flip";
          runtimeInputs = [pkgs.tmux];
          text = ''
            echo "Attaching to server console, press Ctrl+B then D to detach"
            sleep 3
            tmux -S /run/minecraft/flip.sock attach
          '';
        }
      )
    ];
    meenzen.backup.paths = ["/srv/minecraft"];
  };
}
