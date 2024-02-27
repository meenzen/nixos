{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        font = wezterm.font_with_fallback { 'Hack Nerd Font', 'Noto Color Emoji' },
        hide_tab_bar_if_only_one_tab = true,
      }
    '';
  };
}
