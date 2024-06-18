{
  programs.nixvim.plugins = {
    # noice ui
    noice = {
      enable = false;
      presets = {
        bottom_search = true;
        command_palette = true;
        long_message_to_split = true;
      };
    };

    # navigation
    telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
    };
  };
}
