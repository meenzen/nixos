{pkgs, ...}: {
  programs.nixvim.plugins = {
    lualine = {
      enable = true;
      globalstatus = true;
      extensions = [
        "fzf"
      ];
    };
    navic.enable = true; # lualine code structure
    bufferline.enable = true;
  };
}
