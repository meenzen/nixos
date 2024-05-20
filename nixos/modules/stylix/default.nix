{
  pkgs,
  config,
  ...
}: {
  stylix = {
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

      sizes = {
        applications = 10;
        terminal = 12;
        desktop = 10;
        popups = 10;
      };
    };

    opacity = {
      applications = 1.0;
      terminal = 0.9;
      desktop = 1.0;
      popups = 0.9;
    };
  };
}