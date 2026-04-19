{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.determinate-nix;
in {
  options.meenzen.determinate-nix = {
    enable =
      lib.mkEnableOption "Enable Determinate Nix"
      // {
        default = true;
      };
  };

  imports = [
    inputs.determinate.nixosModules.default
  ];

  config = {
    determinate.enable = lib.mkForce cfg.enable;
  };
}
