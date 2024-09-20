{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel

    ../../modules
    ../../hardware/bluetooth

    ./hardware-configuration.nix
  ];
  disabledModules = [
    ../../modules/gaming
  ];

  boot.initrd.luks.devices."luks-d72b6916-393c-4db9-8194-6d48d1cf5189".device = "/dev/disk/by-uuid/d72b6916-393c-4db9-8194-6d48d1cf5189";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  custom.virtualbox.enable = true;
  custom.keyboards.uhk.enable = true;
  custom.certs.enable = true;
}
