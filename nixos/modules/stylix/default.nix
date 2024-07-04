{
  pkgs,
  config,
  ...
}: {
  stylix = {
    enable = true;

    image = pkgs.fetchurl {
      name = "PlasmaDark.jpg";
      url = "https://invent.kde.org/plasma/breeze/-/raw/master/wallpapers/Next/contents/images_dark/base_size.png?inline=false";
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
        package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
      };
      sansSerif = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };
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
  };
}
