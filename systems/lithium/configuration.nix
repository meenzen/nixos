{inputs, ...}: {
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
    profiles.server.enable = true;
    minecraft.enable = false;
    services.forgejo-runner = {
      enable = true;
      uuid = "b01c0895-82fa-4e1a-ab63-4eb873a8645c";
    };
    libvirt.enable = true;
  };
}
