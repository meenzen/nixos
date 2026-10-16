{
  config,
  inputs,
  lib,
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

  options.meenzen.neovim.enable = lib.mkEnableOption "Neovim";

  config = lib.mkIf config.meenzen.neovim.enable {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;

      # Build plugins and LSP servers from the system's nixpkgs instead of nixvim's own pinned instance
      nixpkgs.useGlobalPackages = true;
    };
  };
}
