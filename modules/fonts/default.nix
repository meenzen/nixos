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
    enableFlatpakFix = lib.mkEnableOption "Enable Flatpak font fix";
  };

  config =
    lib.mkIf cfg.enable {
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
          pkgs.noto-fonts-cjk-serif
          pkgs.noto-fonts-color-emoji

          # microsoft fonts
          pkgs.corefonts
          pkgs.vista-fonts
        ];
        fontconfig = {
          enable = true;
          antialias = true;
          cache32Bit = true;
          hinting.enable = true;
          hinting.autohint = true;
          useEmbeddedBitmaps = true;
        };
      };
    }
    // lib.mkIf cfg.enableFlatpakFix {
      system.fsPackages = [pkgs.bindfs];
      fileSystems = let
        mkRoSymBind = path: {
          device = path;
          fsType = "fuse.bindfs";
          options = ["ro" "resolve-symlinks" "x-gvfs-hide"];
        };
        aggregated = pkgs.buildEnv {
          name = "system-fonts-and-icons";
          paths =
            config.fonts.packages
            ++ [
              #pkgs.kdePackages.breeze
              #pkgs.gnome-themes-extra
            ];
          pathsToLink = ["/share/fonts" "/share/icons"];
        };
      in {
        "/usr/share/fonts" = mkRoSymBind "${aggregated}/share/fonts";
        "/usr/share/icons" = mkRoSymBind "${aggregated}/share/icons";
      };
    };
}
