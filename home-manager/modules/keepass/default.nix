{
  config,
  lib,
  pkgs,
  ...
}: {
  options.meenzen.keepass.enable = lib.mkEnableOption "KeePassXC";

  config = lib.mkIf config.meenzen.keepass.enable {
    home.packages = [
      pkgs.keepassxc
    ];
  };
}
