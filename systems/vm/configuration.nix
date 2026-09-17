{lib, ...}: {
  fileSystems."/" = {
    device = "/dev/vda";
    fsType = "ext4";
  };

  system.stateVersion = "25.11";
  networking = {
    hostName = "vm";
    networkmanager.enable = true;
    firewall.enable = true;
    useDHCP = lib.mkDefault true;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.qemuGuest.enable = true;

  meenzen = {
    desktop.enable = true;
    plasma.tiling.enable = true;
  };
}
