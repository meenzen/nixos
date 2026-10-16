{
  config,
  lib,
  pkgs,
  ...
}: {
  options.meenzen.communication.enable = lib.mkEnableOption "communication and mail apps";

  config = lib.mkIf config.meenzen.communication.enable {
    home.packages = [
      pkgs.vesktop
      pkgs.mumble
    ];

    programs.thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };
  };
}
