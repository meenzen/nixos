{
  programs.nixvim = {
    opts.completeopt = ["menu" "menuone" "noselect"];

    plugins = {
      cmp = {
        enable = true;

        settings = {
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";

          mapping = {
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.close()";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };

          sources = [
            {name = "nvim_lsp";} # lsp completion
            {name = "nvim_lsp_signature_help";} # function signatures
            {name = "luasnip";}
            {name = "buffer";} # current buffer
            {name = "path";} # file paths
            {name = "cmdline";} # command line
            {name = "cmp-cmdline-history";} # command line history
            {name = "conventionalcommits";} # conventional commits
            {name = "rg";}
            {name = "copilot";}
          ];
        };
      };

      nix.enable = true;

      # copilot
      copilot-cmp.enable = true;
      copilot-lua.settings = {
        # required to make copilot-cmp work correctly
        panel.enabled = false;
        suggestion.enabled = false;
      };

      # snippets
      luasnip.enable = true;
      friendly-snippets.enable = true;
    };
  };
}
