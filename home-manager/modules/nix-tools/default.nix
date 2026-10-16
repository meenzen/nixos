{
  lib,
  config,
  pkgs,
  ...
}: {
  options.meenzen.nix-tools.enable = lib.mkEnableOption "Nix tools";

  config = lib.mkIf config.meenzen.nix-tools.enable {
    home.packages = [
      pkgs.nix-output-monitor # nom
      pkgs.nix-tree
      pkgs.nil # nix language server
      pkgs.alejandra # nix formatter
    ];
  };
}
