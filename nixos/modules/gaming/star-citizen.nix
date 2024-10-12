{
  config,
  inputs,
  lib,
  ...
}
: let
  cfg = config.custom.gaming.star-citizen;
in {
  options.custom.gaming.star-citizen = {
    enable = lib.mkEnableOption "Enable Star Citizen";
  };

  imports = [
    inputs.nix-citizen.nixosModules.StarCitizen
  ];

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      inputs.nix-citizen.overlays.default
    ];
    nix.settings = {
      substituters = ["https://nix-citizen.cachix.org"];
      trusted-public-keys = ["nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="];
    };

    # https://github.com/LovingMelody/nix-citizen/tree/main/modules/nixos/star-citizen
    nix-citizen.starCitizen = {
      enable = true;
      helperScript.enable = true;
      location = "/games/star-citizen";
    };
  };
}
