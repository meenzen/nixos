{
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.meenzen.gaming;
in {
  options.meenzen.gaming.jovian = {
    enable = lib.mkEnableOption "Enable Jovian";
  };
  imports = [inputs.jovian.nixosModules.jovian];
  config = lib.mkIf cfg.enable {
    jovian = {
      steam = {
        enable = true;
        environment = {
          DXVK_HUD = "compiler";
        };
      };
    };
  };
}
