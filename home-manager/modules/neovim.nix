{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    extraPlugins = with pkgs.vimPlugins; [
      quick-scope
    ];

    globals = {
      mapleader = " ";
      maplocalleader = " ";

      # quick-scope
      qs_highlight_on_keys = "{'f', 'F', 't', 'T'}";
    };

    opts = {
      number = true;
      relativenumber = true;
      expandtab = true;
    };

    clipboard.register = "unnamedplus";

    extraConfigLua = ''
      -- Highlight when yanking text
      vim.api.nvim_create_autocmd('TextYankPost', {
        desc = 'Highlight when yanking (copying) text',
        group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
        callback = function()
          vim.highlight.on_yank()
        end,
      })
    '';

    plugins = {
      # git
      fugitive.enable = true;
      gitsigns = {
        enable = true;
        settings = {
          current_line_blame = true;
          signs = {
            add = {
              text = "+";
            };
            change = {
              text = "~";
            };
            changedelete = {
              text = "~";
            };
            delete = {
              text = "_";
            };
            topdelete = {
              text = "‾";
            };
          };
        };
      };

      # status bar
      lualine = {
        enable = true;
        globalstatus = true;
        extensions = [
          "fzf"
        ];
      };
      bufferline.enable = true;

      # noice ui
      noice = {
        enable = true;
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
        };
      };

      # lsp
      lsp = {
        enable = true;
        servers = {
          marksman.enable = true; # markdown
          nil-ls.enable = true; # nix
          omnisharp.enable = true; # csharp
          rust-analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
        };
      };
      fidget.enable = true;

      # auto-completion
      cmp.enable = true;

      # snippets
      luasnip.enable = true;
      cmp_luasnip.enable = true;
      friendly-snippets.enable = true;

      # lsp completion
      cmp-nvim-lsp.enable = true;
      cmp-path.enable = true;

      cmp-rg.enable = true;
      nix.enable = true;

      # copilot completions
      copilot-cmp.enable = true;
      copilot-lua = {
        # required to make copilot-cmp work correctly
        panel.enabled = false;
        suggestion.enabled = false;
      };

      # navigation
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
      };

      # syntax highlighting
      treesitter.enable = true;
      treesitter-context.enable = true;
      treesitter-refactor.enable = true;
      treesitter-textobjects.enable = true;

      # show keybindings when typing commands
      which-key.enable = true;

      # indentation guides
      indent-blankline.enable = true;

      # tab width auto-detection
      sleuth.enable = true;

      # 'gc' to comment visual blocks
      comment.enable = true;

      # automatically add closing brackets
      nvim-autopairs.enable = true;
    };
  };
}
