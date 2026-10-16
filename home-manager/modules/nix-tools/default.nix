{
  lib,
  config,
  pkgs,
  ...
}: {
  options.meenzen.nix-tools.enable = lib.mkEnableOption "Nix tools";

  config = lib.mkIf config.meenzen.nix-tools.enable {
    # Allow unfree packages in nix shell, nix run and nix-shell
    home.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";

    home.packages = [
      pkgs.nix-output-monitor # nom
      pkgs.nix-tree
      pkgs.nil # nix language server
      pkgs.alejandra # nix formatter
    ];
  };
}
