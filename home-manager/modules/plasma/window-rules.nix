{
  programs.plasma.configFile.kwinrulesrc = {
    General = {
      count = 1;
      rules = "1";
    };

    "1" = {
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
}
