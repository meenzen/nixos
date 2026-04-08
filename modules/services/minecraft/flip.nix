{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.minecraft.flip;
  modpack = pkgs.fetchPackwizModpack {
    url = "https://forge.mnzn.dev/FLiP/minecraft-modpack/raw/commit/49795a147cbec8c2eff472d3611056d6bb22710e/pack.toml";
    packHash = "sha256-ga1mFtnAav+XEb3g/f82Px2NvmWDX4Y59ZH9cN+JFAM=";
    manifestHash = "sha256:1jx576ivf9fj44mgkqai6z42jq0pif356da2w2lmcnml4bbx1ipc";
  };
  mcVersion = modpack.manifest.versions.minecraft;
  fabricVersion = modpack.manifest.versions.fabric;
  serverVersion = lib.replaceStrings ["."] ["_"] "fabric-${mcVersion}";
  website = pkgs.runCommand "build-flip-website" {} ''
    mkdir -p $out
    cp -r ${./flip.mnzn.dev}/* $out/
    # replace the placeholder in the HTML with the actual domain
    sed -i "s/{{DOMAIN}}/${cfg.domain}/g" $out/index.html
    sed -i "s/{{JAVA_EDITION_VERSION}}/${mcVersion}/g" $out/index.html
  '';
in {
  options.meenzen.services.minecraft.flip = {
    enable = lib.mkEnableOption "Enable FLiP Minecraft server";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "flip.mnzn.dev";
      description = "Domain for the FLiP Minecraft server";
    };
    voiceChatPort = lib.mkOption {
      type = lib.types.int;
      default = 24454;
      description = ''
        The port for the Simple Voice Chat server.
      '';
    };
    bedrockPort = lib.mkOption {
      type = lib.types.int;
      default = 19132;
      description = ''
        The port for the GeyserMC Bedrock proxy.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.minecraft-servers.servers.flip = {
      enable = true;
      jvmOpts = "-Xmx8G -Xms2G";
      package = pkgs.fabricServers.${serverVersion}.override {loaderVersion = fabricVersion;};
      symlinks = {
        "mods" = "${modpack}/mods";
      };
    };

    networking.firewall.allowedUDPPorts = [
      cfg.voiceChatPort
      cfg.bedrockPort
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

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      root = website;
    };
  };
}
