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
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        font = wezterm.font_with_fallback { 'Hack Nerd Font', 'Noto Color Emoji' },
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
      # GitLab CLI (glab)
      export GITLAB_HOST=https://git.human.de
      # misc
      export ANSIBLE_NOCOWS=1
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

  # Nicely reload system units when changing configs
  #systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
