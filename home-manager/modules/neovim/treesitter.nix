{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      settings.indent.enable = true;
    };
    treesitter-context.enable = true;
    treesitter-textobjects.enable = true;
    ts-context-commentstring.enable = true;
  };
}
