{
  config,
  inputs,
  lib,
  pkgs,
  systemConfig,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix

    ./minecraft.nix
  ];

  boot = {
    zfs.forceImportRoot = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  networking = {
    hostName = "lithium";
    domain = "localdomain";
    hostId = "cd913f25";
  };
  system.stateVersion = "26.05";

  meenzen = {
    server.enable = true;
    minecraft.enable = false;
    services.forgejo-runner.enable = true;
  };

  age.secrets = {
    gitlabRunnerLithiumNix = {
      file = "${inputs.self}/secrets/gitlabRunnerLithiumNix.age";
    };
    gitlabRunnerLithiumDocker = {
      file = "${inputs.self}/secrets/gitlabRunnerLithiumDocker.age";
    };
  };
}
