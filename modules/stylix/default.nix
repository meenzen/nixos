{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.stylix;
in {
  options.meenzen.stylix = {
    enable = lib.mkEnableOption "Enable Stylix";
  };

  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  config = {
    stylix = {
      enable = cfg.enable;

      image = pkgs.fetchurl {
        name = "PlasmaDark.jpg";
        url = "https://invent.kde.org/plasma/breeze/-/raw/Plasma/6.1/wallpapers/Next/contents/images_dark/base_size.png?ref_type=heads&inline=false";
        sha256 = "sha256-sirjorAnLH4gvP94lXUtPL6iaVP/eaAxz0hIcvQKn+w=";
      };

      polarity = "dark";

      base16Scheme = "${pkgs.base16-schemes}/share/themes/materia.yaml";

      cursor = {
        name = "breeze_cursors";
        package = pkgs.kdePackages.breeze;
        size = 24;
      };

      fonts = rec {
        monospace = {
          name = "JetBrainsMono Nerd Font";
          package = pkgs.nerd-fonts.jetbrains-mono;
        };
        sansSerif = {
          name = "Noto Sans";
          package = pkgs.noto-fonts;
        };

        # serif fonts suck, just force them to sans-serif
        # ¯\_(ツ)_/¯
        serif = sansSerif;

        sizes = let
          default = 10;
          large = 12;
        in {
          applications = default;
          terminal = large;
          desktop = default;
          popups = default;
        };
      };

      opacity = let
        default = 1.0;
        transparent = 0.9;
      in {
        applications = default;
        terminal = transparent;
        desktop = default;
        popups = transparent;
      };

      # The Kvantum theme is broken, see: https://github.com/danth/stylix/issues/835
      targets.qt.platform = "kvantum";
      targets.qt.enable = false;
    };
  };
}
