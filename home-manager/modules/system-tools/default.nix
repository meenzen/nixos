{pkgs, ...}: {
  home.packages = [
    pkgs.strace
    # build failure
    #pkgs.ltrace
    pkgs.lsof

    pkgs.sysstat
    pkgs.lm_sensors # sensors
    pkgs.ethtool
    pkgs.pciutils # lspci
    pkgs.usbutils # lsusb
    pkgs.cyme # better lsusb
    pkgs.smartmontools # smartctl

    pkgs.htop
    pkgs.btop
    pkgs.iotop-c
    pkgs.iftop
    pkgs.duf
    pkgs.ncdu

    # gpu related tools
    pkgs.mesa-demos
    pkgs.vulkan-tools
    pkgs.gpu-viewer

    pkgs.zip
    pkgs.xz
    pkgs.unzip
    pkgs.p7zip
    pkgs.zstd

    pkgs.file
    pkgs.which
    pkgs.tree
    pkgs.gnused
    pkgs.gnutar
    pkgs.gawk
    pkgs.gnupg
    pkgs.dos2unix

    pkgs.nnn # terminal file manager
    pkgs.ripgrep # grep alternative
    pkgs.jq # json processer
    pkgs.yq-go # yaml processer
    pkgs.eza # ls alternative
    pkgs.fzf # fuzzy finder
    pkgs.bat # cat alternative
  ];
}
