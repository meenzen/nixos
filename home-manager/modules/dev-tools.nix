{
  pkgs,
  inputs,
  ...
}: let
  # own nixpkgs with some updated packages
  meenzen = import inputs.nixpkgs-meenzen {
    system = pkgs.system;
    config.allowUnfree = true;
  };

  dotnet-combined =
    (with pkgs.dotnetCorePackages;
      combinePackages [
        sdk_8_0
        sdk_7_0
        sdk_6_0
      ])
    .overrideAttrs (finalAttrs: previousAttrs: {
      # This is needed to install workload in $HOME
      # https://discourse.nixos.org/t/dotnet-maui-workload/20370/12

      postBuild =
        (previousAttrs.postBuild or '''')
        + ''
          for i in $out/sdk/*
          do
            i=$(basename $i)
            length=$(printf "%s" "$i" | wc -c)
            substring=$(printf "%s" "$i" | cut -c 1-$(expr $length - 2))
            i="$substring""00"
            mkdir -p $out/metadata/workloads/''${i/-*}
            touch $out/metadata/workloads/''${i/-*}/userlocal
          done
        '';
    });

  jetbrains-plugins = ["github-copilot" "ideavim"];
in {
  home.sessionVariables = {
    DOTNET_ROOT = "${dotnet-combined}";
  };
  home.packages = with pkgs; [
    # Compilers
    dotnet-combined
    gcc

    # Editors
    vscode
    kdePackages.kate

    # https://nixos.wiki/wiki/Jetbrains_Tools
    (meenzen.jetbrains.plugins.addPlugins meenzen.jetbrains.rider jetbrains-plugins)
    (meenzen.jetbrains.plugins.addPlugins meenzen.jetbrains.rust-rover jetbrains-plugins)
    (meenzen.jetbrains.plugins.addPlugins meenzen.jetbrains.idea-ultimate jetbrains-plugins)
    (meenzen.jetbrains.plugins.addPlugins meenzen.jetbrains.webstorm jetbrains-plugins)
    #jetbrains-toolbox

    # Rust
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt

    # Misc
    hyperfine
    glow
    tokei
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

    " Don't use Ex mode, use Q for formatting.
    map Q gq

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
