{pkgs, ...}: {
  programs.nixvim = {
    # Highlight f/F like quickscope
    extraPlugins = [
      pkgs.vimPlugins.eyeliner-nvim
    ];

    extraConfigLua = ''
      require'eyeliner'.setup {
        highlight_on_key = true,
        dim = true,
      }
    '';
  };
}
