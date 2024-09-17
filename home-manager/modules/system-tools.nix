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
    cyme # better lsusb
    smartmontools # smartctl

    htop
    btop
    iotop-c
    iftop
    duf
    ncdu

    # gpu related tools
    glxinfo
    vulkan-tools
    gpu-viewer

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
    dos2unix

    nnn # terminal file manager
    ripgrep # grep alternative
    jq # json processer
    yq-go # yaml processer
    eza # ls alternative
    fzf # fuzzy finder
    bat # cat alternative
  ];
}
