{
  programs.nixvim.plugins = {
    copilot-chat.enable = true;

    # tab width auto-detection
    sleuth.enable = true;

    # 'gc' to comment visual blocks
    comment.enable = true;

    # automatically add closing brackets
    nvim-autopairs.enable = true;

    # indentation guides
    indent-blankline.enable = true;

    # show keybindings when typing commands
    which-key.enable = true;

    # icons needed for some plugins
    web-devicons.enable = true;
  };
}
