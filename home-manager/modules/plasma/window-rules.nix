{
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.meenzen.plasma.windowRules;
  defaultRules = {
    pin-picture-in-picture = {
      Description = "Pin Picture in Picture";

      wmclass = "brave";
      wmclassmatch = 1;
      title = "Picture in picture";
      titlematch = 1;

      above = true;
      aboverule = 2;
      desktops = "\\0";
      desktopsrule = 2;
      skippager = true;
      skippagerrule = 2;
      skipswitcher = true;
      skipswitcherrule = 2;
      skiptaskbar = true;
      skiptaskbarrule = 2;
    };
  };
in {
  options.meenzen.plasma.windowRules = lib.mkOption {
    type = lib.types.attrs;
    default = defaultRules;
    apply = x: lib.recursiveUpdate defaultRules x;
    description = ''
      Define custom window rules for KDE Plasma's KWin window manager.
      Each rule should be an attribute set with properties corresponding to KWin's window rules.
      Refer to KWin documentation for available properties.
    '';
  };

  config = lib.mkIf osConfig.meenzen.plasma.enable {
    programs.plasma.configFile.kwinrulesrc =
      {
        General = {
          count = toString (builtins.length (builtins.attrNames cfg));
          # comma separated list of rule ids
          rules = builtins.concatStringsSep "," (builtins.attrNames cfg);
        };
      }
      // cfg;
  };
}
