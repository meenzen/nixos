# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "meenzens";
    homeDirectory = "/home/meenzens";

    # Environt Variables
    sessionVariables = {
      GITLAB_HOST = "https://git.human.de";
      ANSIBLE_NOCOWS = "1";
    };
  };

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
  #xresources.properties = {
  #  "Xcursor.size" = 16;
  #  "Xft.dpi" = 172;
  #};

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    htop
    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # archives
    zip
    xz
    unzip
    p7zip

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing

    # devtools
    vscode
    kate
    jetbrains.rider
    rustup
    
    # webbrowser
    firefox
    brave
    microsoft-edge

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    glow
    bat
    neofetch
    nnn # terminal file manager
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    tokei
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Samuel Meenzen";
    userEmail = "samuel@meenzen.net";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      rerere = {
        enabled = true;
      };
    };
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = true;
      format = "$all";
      character = {
        success_symbol = "[](fg:#33658A)";
        error_symbol = "[](fg:#33658A bg:#8B0000)[ ! ](bg:#8B0000)[](fg:#8B0000)";
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
          { threshold = 10; style = "bold red bg:#696969"; }
          { threshold = 30; style = "bold yellow bg:#696969"; }
          { threshold = 80; style = "bg:#696969"; }
        ];
      };

      # Packages
      aws.symbol = ''  '';
      aws.format = ''\[[$symbol($profile)(\($region\))(\[$duration\])]($style)\]'';
      aws.disabled = true;
      buf.symbol = '' '';
      bun.format = ''\[[$symbol($version)]($style)\]'';
      c.symbol = '' '';
      c.format = ''\[[$symbol($version(-$name))]($style)\]'';
      cmake.format = ''\[[$symbol($version)]($style)\]'';
      cmd_duration.format = ''\[[⏱ $duration]($style)\]'';
      cobol.format = ''\[[$symbol($version)]($style)\]'';
      conda.symbol = " ";
      conda.format = ''\[[$symbol$environment]($style)\]'';
      dart.symbol = " ";
      dart.format = ''\[[$symbol($version)]($style)\]'';
      docker_context.symbol = " ";
      docker_context.format = ''\[[$symbol$context]($style)\]'';
      elixir.symbol = " ";
      elixir.format = ''\[[$symbol($version \(OTP $otp_version\))]($style)\]'';
      elm.symbol = " ";
      elm.format = ''\[[$symbol($version)]($style)\]'';
      git_branch.symbol = " ";
      git_branch.format = ''\[[$symbol$branch]($style)\]'';
      git_status.format = ''([\[$all_status$ahead_behind\]]($style))'';
      golang.symbol = " ";
      golang.format = ''\[[$symbol($version)]($style)\]'';
      haskell.symbol = " ";
      haskell.format = ''\[[$symbol($version)]($style)\]'';
      hg_branch.symbol = " ";
      hg_branch.format = ''\[[$symbol$branch]($style)\]'';
      java.symbol = " ";
      java.format = ''\[[$symbol($version)]($style)\]'';
      julia.format = ''\[[$symbol($version)]($style)\]'';
      julia.symbol = " ";
      kotlin.format = ''\[[$symbol($version)]($style)\]'';
      lua.symbol = " ";
      lua.format = ''\[[$symbol($version)]($style)\]'';
      #memory_usage.symbol = " ";
      memory_usage.format = ''\[$symbol[$ram( | $swap)]($style)\]'';
      #nim.symbol = " ";
      nim.format = ''\[[$symbol($version)]($style)\]'';
      nix_shell.symbol = " ";
      nix_shell.format = ''\[[$symbol$state( \($name\))]($style)\]'';
      nodejs.symbol = '' '';
      nodejs.format = ''\[[$symbol($version)]($style)\]'';
      #package.symbol = " ";
      package.format = ''\[[$symbol$version]($style)\]'';
      python.symbol = " ";
      python.format = ''\[[''${symbol}''${pyenv_prefix}(''${version})(\($virtualenv\))]($style)\]'';
      rlang.symbol = "ﳒ ";
      ruby.symbol = " ";
      ruby.format = ''\[[$symbol($version)]($style)\]'';
      rust.symbol = " ";
      rust.format = ''\[[$symbol($version)]($style)\]'';
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

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        font = wezterm.font_with_fallback { 'Hack Nerd Font', 'Noto Color Emoji' },
        font_size = 16.0,
        hide_tab_bar_if_only_one_tab = true,
      }
    '';
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin"
      # dotnet
      export PATH=$PATH:$HOME/dotnet
      export PATH=$PATH:$HOME/.dotnet/tools
      export DOTNET_ROOT=$HOME/dotnet
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      nano = "nvim";
      vi = "nvim";
      vim = "nvim";
      ls = "exa";
      top = "htop";
      grep = "rg";
      weather = "curl wttr.in/Wiesbaden";
    };
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting = {
      enable = true;
    };
    oh-my-zsh = {
      plugins = ["git" "sudo" "docker"];
    };
    shellAliases = {
      nano = "nvim";
      vi = "nvim";
      vim = "nvim";
      ls = "exa";
      top = "htop";
      grep = "rg";
      weather = "curl wttr.in/Wiesbaden";
    };
  };

  programs.fish = {
    enable = true;
  };

  programs.nushell = {
    enable = true;
  };

  # Nicely reload system units when changing configs
  #systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
