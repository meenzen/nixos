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
          url = "https://forge.mnzn.dev/FLiP/minecraft-modpack/raw/commit/43c70e1ce77d146c481b36fdec38fc045b8630cb/pack.toml";
          packHash = "sha256-Yq7v5WVXr0L8sAHKexStWWdcdyg7+zibFO7JcEz1idQ=";
          manifestHash = "sha256:097nfrd8makps19l6bn3ama93phg1r7c4s85azcpsr5fmccwkfwn";
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
