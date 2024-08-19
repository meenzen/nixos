{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        hide_tab_bar_if_only_one_tab = true,
        front_end = "WebGpu",
      }
    '';
  };

  # alternative until https://github.com/wez/wezterm/issues/5990 is fixed
  programs.alacritty = {
    enable = true;
  };
}
