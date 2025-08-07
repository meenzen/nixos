{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.distributed-build;
in {
  options.meenzen.distributed-build = {
    enable = lib.mkEnableOption "Enable distributed build support";
    enableHost = lib.mkEnableOption "Enable distributed build host";
    user = lib.mkOption {
      type = lib.types.str;
      default = "builder";
      description = "SSH user for the distributed build host.";
    };
  };

  imports = [
    ./host.nix
  ];

  config = lib.mkIf cfg.enable {
    nix.buildMachines = [
      {
        hostName = "neon.mnzn.dev";
        sshUser = cfg.user;
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 4;
        speedFactor = 2;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      }
      {
        hostName = "mergeatron.human-dev.io";
        sshUser = cfg.user;
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 4;
        speedFactor = 2;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      }
    ];
    nix.distributedBuilds = true;
    # optional, useful when the builder has a faster internet connection than yours
    nix.extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
