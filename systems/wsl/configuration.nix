{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  system.stateVersion = "23.11";
  networking.hostName = "wsl";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  wsl = {
    enable = true;
    defaultUser = config.meenzen.user.username;
  };

  meenzen.home-manager = {
    enable = true;
    homeModule = "${inputs.self}/home-manager/cli.nix";
  };
}
