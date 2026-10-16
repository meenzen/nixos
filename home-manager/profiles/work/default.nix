{
  config,
  lib,
  osConfig,
  ...
}: let
  cfg = config.meenzen.profiles.work;
in {
  options.meenzen.profiles.work = {
    enable =
      lib.mkEnableOption "work configuration"
      // {default = osConfig.meenzen.work.enable;};
  };

  config = lib.mkIf cfg.enable {
    meenzen = {
      ssh.enable = true;
      work.enable = true;
    };
  };
}
