{pkgs, ...}: {
  programs.nixvim.plugins = {
    lualine = {
      enable = true;
      settings = {
        extensions = [
          "fzf"
        ];
        options.globalstatus = true;
      };
    };
    navic.enable = true; # lualine code structure
    bufferline.enable = true;
  };
}
