{pkgs, ...}: {
  home.packages = with pkgs; [
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    htop
    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring
    duf
    ncdu

    zip
    xz
    unzip
    p7zip

    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    nnn # terminal file manager
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    bat
  ];
}
