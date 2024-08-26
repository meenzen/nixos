{
  pkgs,
  inputs,
  ...
}: {
  programs.wezterm = {
    package = inputs.wezterm.packages.${pkgs.system}.default;
    enable = true;
    extraConfig = ''
      return {
        hide_tab_bar_if_only_one_tab = true,
      }
    '';
  };
}
