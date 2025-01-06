{...}: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        hide_tab_bar_if_only_one_tab = true,
      }
    '';
  };

  # Alternate terminal emulator
  programs.alacritty.enable = true;
}
