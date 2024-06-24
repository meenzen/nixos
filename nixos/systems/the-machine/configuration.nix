{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime

    ../../modules
    ../../hardware/nvidia
    ../../hardware/bluetooth

    ./hardware-configuration.nix
  ];
  disabledModules = [
    ../../modules/certs
  ];

  # Mounts
  fileSystems."/games" = {
    device = "/dev/disk/by-uuid/0f7c57b0-a681-4b2a-b89d-6940465b22d2";
    fsType = "ext4";
    options = [
      "defaults"
      "discard"
      "noatime"
      "nofail"
    ];
  };

  # Wootility
  hardware.wooting.enable = true;
}
