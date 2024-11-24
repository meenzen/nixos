{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.oci-containers;
in {
  options.meenzen.oci-containers = {
    enable = lib.mkEnableOption "Enable OCI container support";
  };

  imports = [
    inputs.arion.nixosModules.arion
  ];

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.dive # look into docker image layers
      pkgs.podman-tui # status of containers in the terminal
      pkgs.podman-compose
    ];
    virtualisation.docker.enable = false;
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings = {
        dns_enabled = true;
      };
      autoPrune = {
        enable = true;
        dates = "daily";
        flags = ["--all"];
      };
    };
    virtualisation.arion = {
      backend = "podman-socket";
    };

    # Allow DNS and mDNS so that containers can resolve hostnames
    networking.firewall.interfaces."podman+".allowedUDPPorts = [53 5353];
  };
}
