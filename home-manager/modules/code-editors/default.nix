{
  pkgs,
  inputs,
  ...
}: let
  # plugins are currently broken, see https://github.com/nixos/nixpkgs/issues/400317
  #jetbrains-plugins = ["github-copilot" "ideavim"];
  jetbrains-plugins = [];
in {
  home.packages = [
    # Editors
    pkgs.vscode
    pkgs.kdePackages.kate

    # https://nixos.wiki/wiki/Jetbrains_Tools
    #(meenzen.jetbrains.plugins.addPlugins meenzen.jetbrains.rider jetbrains-plugins)
    (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rider jetbrains-plugins)
    (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rust-rover jetbrains-plugins)
    (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.webstorm jetbrains-plugins)
    #pkgs.jetbrains-toolbox
  ];

  home.file.".ideavimrc".text = ''
    " .ideavimrc is a configuration file for IdeaVim plugin. It uses
    "   the same commands as the original .vimrc configuration.
    " You can find a list of commands here: https://jb.gg/h38q75
    " Find more examples here: https://jb.gg/share-ideavimrc

    "" -- Suggested options --
    " Show a few lines of context around the cursor. Note that this makes the
    " text scroll if you mouse-click near the start or end of the window.
    set scrolloff=5

    " Do incremental searching.
    set incsearch

    " J - Join things.
    set ideajoin

    " Case-insensitive search.
    set ignorecase smartcase

    " Don't use Ex mode, use Q for formatting.
    map Q gq

    " Use relative line numbers.
    set relativenumber number

    " --- Enable IdeaVim plugins https://jb.gg/ideavim-plugins

    " Highlight copied text
    Plug 'machakann/vim-highlightedyank'
    " Commentary plugin
    Plug 'tpope/vim-commentary'

    " Quickscope plugin (install IdeaVim-Quickscope in Settings | Plugins)
    set quickscope
    let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

    "" -- Map IDE actions to IdeaVim -- https://jb.gg/abva4t
    "" Map \r to the Reformat Code action
    map \r <Action>(ReformatCode)

    "" Map <leader>d to start debug
    "map <leader>d <Action>(Debug)

    "" Map \b to toggle the breakpoint on the current line
    map \b <Action>(ToggleLineBreakpoint)
  '';
}
