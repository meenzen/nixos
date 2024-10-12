{
  programs.nixvim.plugins = {
    lsp = {
      enable = true;
      servers = {
        marksman.enable = true; # markdown
        nil_ls.enable = true; # nix
        omnisharp.enable = true; # csharp
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
      };
    };
    fidget.enable = true; # improved progress messages and notifications
    lspkind.enable = true; # completion icons
  };
}
