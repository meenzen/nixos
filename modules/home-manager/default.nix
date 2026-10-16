{
  config,
  pkgs-review,
  lib,
  inputs,
  ...
}: let
  cfg = config.meenzen.home-manager;
in {
  options.meenzen.home-manager = {
    enable = lib.mkEnableOption "Home Manager";
  };

  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = lib.mkIf cfg.enable {
    home-manager = {
      extraSpecialArgs = {
        inherit inputs pkgs-review;
      };
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      users."${config.meenzen.user.username}" = ../../home-manager;
      sharedModules = [inputs.plasma-manager.homeModules.plasma-manager];
    };
  };
}
