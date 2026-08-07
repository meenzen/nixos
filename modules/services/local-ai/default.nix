{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.services.local-ai;
in {
  options.meenzen.services.local-ai = {
    enable = lib.mkEnableOption "Enable Local AI";
    ollamaPort = lib.mkOption {
      type = lib.types.int;
      default = 11434;
      description = "Port for the Ollama API";
    };
    uiPort = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "Port for the Local AI web UI";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      port = cfg.ollamaPort;
      openFirewall = true;
    };

    nix.settings = {
      substituters = ["https://cache.nixos-cuda.org"];
      trusted-public-keys = ["cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="];
    };

    services.open-webui = {
      enable = true;
      port = cfg.uiPort;
      openFirewall = true;
    };
  };
}
