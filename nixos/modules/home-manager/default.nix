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
    homeModule = lib.mkOption {
      type = lib.types.path;
      default = ../../../home-manager/home.nix;
      description = ''
        Path to the home-manager module of the main user.
      '';
    };

    extraConfig = let
      defaultExtraConfig = {
        additionalPinnedApps = [];
        additionalShownSystemTrayItems = [];
      };
    in
      lib.mkOption {
        type = lib.types.attrs;
        default = defaultExtraConfig;
        apply = x: lib.recursiveUpdate defaultExtraConfig x;
        description = ''
          Extra configuration to pass to the home-manager of the main user.
        '';
      };
  };

  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager = {
      extraSpecialArgs = {
        inherit inputs outputs systemConfig;
        extraConfig = cfg.extraConfig;
      };
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      users."${systemConfig.user.username}" = import cfg.homeModule;
      sharedModules = [inputs.plasma-manager.homeManagerModules.plasma-manager];
    };
  };
}
