{
  config,
  lib,
  pkgs-stable,
  ...
}: let
  cfg = config.meenzen.verapdf;
in {
  options.meenzen.verapdf = {
    enable = lib.mkEnableOption "veraPDF";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs-stable.verapdf
    ];
  };
}
