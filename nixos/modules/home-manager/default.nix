{
  config,
  lib,
  inputs,
  outputs,
  systemConfig,
  ...
}: let
  cfg = config.custom.home-manager;
in {
  options.custom.home-manager = {
    module = lib.mkOption {
      type = lib.types.path;
      default = ../../../home-manager/home.nix;
      description = ''
        Path to the home-manager module of the main user.
      '';
    };
  };

  imports = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        extraSpecialArgs = {
          inherit inputs outputs systemConfig;
        };
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users."${systemConfig.user.username}" = import cfg.module;
        sharedModules = [inputs.plasma-manager.homeManagerModules.plasma-manager];
      };
    }
  ];
}
