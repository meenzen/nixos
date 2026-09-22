{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
    
    inputs.disko.nixosModules.disko
    ./disko.nix
    
    ./hardware-configuration.nix
  ];

  system.stateVersion = "26.05";
  networking = {
    hostName = "framework";
    hostId = "b2bb15e5";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  meenzen = {
    desktop.enable = true;
  };
}
