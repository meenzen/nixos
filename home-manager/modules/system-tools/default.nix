{
  config,
  lib,
  pkgs,
  ...
}: {
  options.meenzen.system-tools.enable = lib.mkEnableOption "system tools";

  config = lib.mkIf config.meenzen.system-tools.enable {
    home.packages = [
      pkgs.strace
      pkgs.ltrace
      pkgs.lsof

      pkgs.sysstat
      pkgs.lm_sensors # sensors
      pkgs.ethtool
      pkgs.pciutils # lspci
      pkgs.usbutils # lsusb
      pkgs.cyme # better lsusb
      pkgs.smartmontools # smartctl
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
      pkgs.yq-go # yaml processor
      pkgs.fzf # fuzzy finder
    ];

    programs = {
      bat.enable = true; # cat alternative
      btop.enable = true;
      eza.enable = true; # ls alternative
      htop.enable = true;
      jq.enable = true; # json processor
      nnn.enable = true; # terminal file manager
      ripgrep.enable = true; # grep alternative
    };
  };
}
