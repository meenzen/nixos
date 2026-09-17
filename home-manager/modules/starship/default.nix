{
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = true;
      format = "$all";
      character = {
        success_symbol = "[](fg:#33658A)";
        error_symbol = "[](fg:#33658A bg:#8B0000)[ ! ](bg:#8B0000)[](fg:#8B0000)";
        vimcmd_symbol = "[](fg:#33658A bg:#008080)[ VIM ](bg:#008080)[](fg:#008080)";
      };
      directory = {
        read_only = " 󰌾";
        truncation_length = 3;
        truncate_to_repo = true;
        truncation_symbol = "…/";
        home_symbol = "󰋜 ";
        substitutions = {
          "Documents" = "󰈙 ";
          "Dokumente" = "󰈙 ";
          "Downloads" = " ";
          "Music" = " ";
          "Musik" = " ";
          "Pictures" = " ";
          "Bilder" = " ";
        };
      };
      time = {
        disabled = false;
        time_format = "%R"; # Hour:Minute Format
        style = "bg:#33658A";
        format = "[ $time ]($style)";
      };
      battery = {
        format = "[ $symbol$percentage ]($style)[](fg:#696969 bg:#33658A)";
        display = [
          {
            threshold = 10;
            style = "bold red bg:#696969";
          }
          {
            threshold = 30;
            style = "bold yellow bg:#696969";
          }
          {
            threshold = 80;
            style = "bg:#696969";
          }
        ];
      };

      # Packages
      aws = {
        symbol = ''  '';
        format = ''\[[$symbol($profile)(\($region\))(\[$duration\])]($style)\]'';
        disabled = true;
      };
      buf.symbol = '' '';
      bun.format = ''\[[$symbol($version)]($style)\]'';
      c = {
        symbol = '' '';
        format = ''\[[$symbol($version(-$name))]($style)\]'';
      };
      cmake.format = ''\[[$symbol($version)]($style)\]'';
      cmd_duration.format = ''\[[⏱ $duration]($style)\]'';
      cobol.format = ''\[[$symbol($version)]($style)\]'';
      conda = {
        symbol = " ";
        format = ''\[[$symbol$environment]($style)\]'';
      };
      dart = {
        symbol = " ";
        format = ''\[[$symbol($version)]($style)\]'';
      };
      docker_context = {
        symbol = " ";
        format = ''\[[$symbol$context]($style)\]'';
      };
      elixir = {
        symbol = " ";
        format = ''\[[$symbol($version \(OTP $otp_version\))]($style)\]'';
      };
      elm = {
        symbol = " ";
        format = ''\[[$symbol($version)]($style)\]'';
      };
      git_branch = {
        symbol = " ";
        format = ''\[[$symbol$branch]($style)\]'';
      };
      git_status = {
        format = ''([\[$all_status$ahead_behind\]]($style))'';
        behind = "↓$count";
        ahead = "↑$count";
      };
      golang = {
        symbol = " ";
        format = ''\[[$symbol($version)]($style)\]'';
      };
      haskell = {
        symbol = " ";
        format = ''\[[$symbol($version)]($style)\]'';
      };
      hg_branch = {
        symbol = " ";
        format = ''\[[$symbol$branch]($style)\]'';
      };
      java = {
        symbol = " ";
        format = ''\[[$symbol($version)]($style)\]'';
      };
      julia = {
        format = ''\[[$symbol($version)]($style)\]'';
        symbol = " ";
      };
      kotlin.format = ''\[[$symbol($version)]($style)\]'';
      lua = {
        symbol = " ";
        format = ''\[[$symbol($version)]($style)\]'';
      };
      memory_usage.format = ''\[$symbol[$ram( | $swap)]($style)\]'';
      nim.format = ''\[[$symbol($version)]($style)\]'';
      nix_shell = {
        symbol = " ";
        format = ''\[[$symbol$state( \($name\))]($style)\]'';
      };
      nodejs = {
        symbol = '' '';
        format = ''\[[$symbol($version)]($style)\]'';
      };
      package.format = ''\[[$symbol$version]($style)\]'';
      python = {
        symbol = " ";
        format = ''\[[''${symbol}''${pyenv_prefix}(''${version})(\($virtualenv\))]($style)\]'';
      };
      rlang.symbol = "ﳒ ";
      ruby = {
        symbol = " ";
        format = ''\[[$symbol($version)]($style)\]'';
      };
      rust = {
        symbol = " ";
        format = ''\[[$symbol($version)]($style)\]'';
      };
      spack.symbol = "🅢 ";
      spack.format = ''\[[$symbol$environment]($style)\]'';
      crystal.format = ''\[[$symbol($version)]($style)\]'';
      daml.format = ''\[[$symbol($version)]($style)\]'';
      deno.format = ''\[[$symbol($version)]($style)\]'';
      dotnet.format = ''\[[$symbol($version)(🎯 $tfm)]($style)\]'';
      erlang.format = ''\[[$symbol($version)]($style)\]'';
      gcloud.format = ''\[[$symbol$account(@$domain)(\($region\))]($style)\]'';
      helm.format = ''\[[$symbol($version)]($style)\]'';
      kubernetes.format = ''\[[$symbol$context( \($namespace\))]($style)\]'';
      ocaml.format = ''\[[$symbol($version)(\($switch_indicator$switch_name\))]($style)\]'';
      openstack.format = ''\[[$symbol$cloud(\($project\))]($style)\]'';
      perl.format = ''\[[$symbol($version)]($style)\]'';
      php.format = ''\[[$symbol($version)]($style)\]'';
      pulumi.format = ''\[[$symbol$stack]($style)\]'';
      purescript.format = ''\[[$symbol($version)]($style)\]'';
      raku.format = ''\[[$symbol($version-$vm_version)]($style)\]'';
      red.format = ''\[[$symbol($version)]($style)\]'';
      scala.format = ''\[[$symbol($version)]($style)\]'';
      sudo.format = ''\[[as $symbol]\]'';
      swift.format = ''\[[$symbol($version)]($style)\]'';
      terraform.format = ''\[[$symbol$workspace]($style)\]'';
      username.format = ''\[[$user]($style)\]'';
      vagrant.format = ''\[[$symbol($version)]($style)\]'';
      vlang.format = ''\[[$symbol($version)]($style)\]'';
      zig.format = ''\[[$symbol($version)]($style)\]'';
    };
  };
}
