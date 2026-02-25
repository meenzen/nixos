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
    bluemapPort = lib.mkOption {
      type = lib.types.int;
      default = 8100;
      description = ''
        The port for the BlueMap web server.
        This is used to view the map in a web browser.
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
      servers.paper = {
        enable = true;
        jvmOpts = "-Xmx8G -Xms2G";
        package = pkgs.paperServers.paper-1_21_11;
        symlinks = {
          "plugins/bluemap.jar" = pkgs.fetchurl {
            url = "https://github.com/BlueMap-Minecraft/BlueMap/releases/download/v5.16/bluemap-5.16-paper.jar";
            hash = "sha256-eduusmBTLb1WYk+LzoqyL7yhWK5KKGCwT8zv+55Gdso=";
            name = "bluemap.jar";
          };
          "plugins/BlueMap/core.conf" = pkgs.writeTextFile {
            name = "core.conf";
            text = ''
              accept-download: true
              data: "bluemap"
              render-thread-count: 3
              metrics: false
            '';
          };
          "plugins/BlueMap/webserver.conf" = pkgs.writeTextFile {
            name = "webserver.conf";
            text = ''
              enabled: true
              webroot: "bluemap/web"
              port: ${toString cfg.bluemapPort}
            '';
          };
        };
      };
    };
    networking.firewall.allowedTCPPorts = [
      cfg.bluemapPort
    ];
    environment.systemPackages = [
      pkgs.tmux
      (
        pkgs.writeShellApplication {
          name = "minecraft-console-paper";
          runtimeInputs = [pkgs.tmux];
          text = ''
            echo "Attaching to server console, press Ctrl+B then D to detach"
            sleep 3
            tmux -S /run/minecraft/paper.sock attach
          '';
        }
      )
    ];
  };
}
