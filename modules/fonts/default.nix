{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.fonts;
in {
  options.meenzen.fonts = {
    enable = lib.mkEnableOption "Add Fonts";
  };

  config = lib.mkIf cfg.enable {
    # Fonts
    system.fsPackages = [pkgs.bindfs];
    fileSystems = let
      mkRoSymBind = path: {
        device = path;
        fsType = "fuse.bindfs";
        options = ["ro" "resolve-symlinks" "x-gvfs-hide"];
      };
      aggregatedIcons = pkgs.buildEnv {
        name = "system-icons";
        paths = [
          pkgs.kdePackages.breeze # for plasma
          pkgs.gnome-themes-extra
        ];
        pathsToLink = ["/share/icons"];
      };
      aggregatedFonts = pkgs.buildEnv {
        name = "system-fonts";
        paths = config.fonts.packages;
        pathsToLink = ["/share/fonts"];
      };
    in {
      "/usr/share/icons" = mkRoSymBind "${aggregatedIcons}/share/icons";
      "/usr/local/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";
    };

    fonts = {
      fontDir.enable = true;
      packages = [
        pkgs.nerd-fonts.fira-code
        pkgs.nerd-fonts.hack
        pkgs.nerd-fonts.jetbrains-mono

        # default fonts
        pkgs.dejavu_fonts
        pkgs.freefont_ttf
        pkgs.gyre-fonts # TrueType substitutes for standard PostScript fonts
        pkgs.liberation_ttf
        pkgs.unifont
        pkgs.noto-fonts
        pkgs.noto-fonts-cjk-sans
        pkgs.noto-fonts-color-emoji

        # microsoft fonts
        pkgs.corefonts
        pkgs.vista-fonts
      ];
      fontconfig = {
        antialias = true;
        cache32Bit = true;
        hinting.enable = true;
        hinting.autohint = true;
      };
    };
  };
}
