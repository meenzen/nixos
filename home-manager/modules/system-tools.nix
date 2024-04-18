{pkgs, ...}: {
  home.packages = with pkgs; [
    strace
    ltrace
    lsof

    sysstat
    lm_sensors # sensors
    ethtool
    pciutils # lspci
    usbutils # lsusb
    smartmontools # smartctl

    htop
    btop
    iotop
    iftop
    duf
    ncdu

    zip
    xz
    unzip
    p7zip
    zstd

    file
    which
    tree
    gnused
    gnutar
    gawk
    gnupg

    nnn # terminal file manager
    ripgrep # grep alternative
    jq # json processer
    yq-go # yaml processer
    eza # ls alternative
    fzf # fuzzy finder
    bat # cat alternative
  ];
}
