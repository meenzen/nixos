{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./completions.nix
    ./eyeliner.nix
    ./git.nix
    ./highlight-yank.nix
    ./keymaps.nix
    ./lsp.nix
    ./options.nix
    ./plugins.nix
    ./status-bar.nix
    ./treesitter.nix
    ./ui.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    # Fix infinite recursion: https://github.com/nix-community/nixvim/issues/4460
    nixpkgs.useGlobalPackages = true;
  };
}
