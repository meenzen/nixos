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
        paths = with pkgs; [
          kdePackages.breeze # for plasma
          gnome-themes-extra
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
      packages = with pkgs; [
        pkgs.nerd-fonts.fira-code
        pkgs.nerd-fonts.hack
        pkgs.nerd-fonts.jetbrains-mono

        # default fonts
        dejavu_fonts
        freefont_ttf
        gyre-fonts # TrueType substitutes for standard PostScript fonts
        liberation_ttf
        unifont
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        noto-fonts-emoji

        # microsoft fonts
        corefonts
        vistafonts
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
