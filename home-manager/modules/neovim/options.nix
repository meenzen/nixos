{
  programs.nixvim = {
    colorschemes.vscode.enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";

      editorconfig = true;
    };

    opts = {
      number = true; # line numbers
      relativenumber = true; # relative line numbers
      cursorline = true; # highlight current line
      lazyredraw = true; # don't redraw while executing macros
      showmatch = true; # highlight matching brackets
      scrolloff = 5; # minimum number of lines to keep above and below the cursor
      wrap = false; # wrap lines
      expandtab = true; # spaces instead of tabs
      updatetime = 100; # completion update time
      textwidth = 120; # text width
      termguicolors = true; # true color support
      swapfile = false; # don't create swap files
      undofile = true; # persistent undo

      # search
      incsearch = true; # incremental search
      hlsearch = true; # highlight search results
      ignorecase = true; # case insensitive search
      smartcase = true; # case sensitive search if any uppercase letters are used

      # spell checking
      spell = true; # spell checking
      spelllang = "en_us"; # spell checking language
    };

    clipboard.register = "unnamedplus";
  };
}
