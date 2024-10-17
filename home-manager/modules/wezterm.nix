{...}: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        hide_tab_bar_if_only_one_tab = true,

        -- Workaround for https://github.com/NixOS/nixpkgs/issues/336069
        front_end = "WebGpu",
        enable_wayland = false,
      }
    '';
  };
}
