{
  programs.nixvim.keymaps = [
    # Save using Ctrl+S
    {
      mode = "n";
      key = "<C-s>";
      action = "<cmd>w<CR>";
      options.desc = "Save";
    }
    # Undo using Ctrl+Z
    {
      mode = "n";
      key = "<C-z>";
      action = "<cmd>u<CR>";
      options.desc = "Undo";
    }
  ];
}
