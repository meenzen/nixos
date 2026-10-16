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

    homeModule = lib.mkOption {
      type = lib.types.path;
      default = "${inputs.self}/home-manager/home.nix";
      description = ''
        Path to the home-manager module of the main user.
      '';
    };
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
      users."${config.meenzen.user.username}" = import cfg.homeModule;
      sharedModules = [inputs.plasma-manager.homeModules.plasma-manager];
    };
  };
}
