{pkgs, ...}: {
  home.packages = [
    pkgs.nix-output-monitor # nom
    pkgs.nix-tree
    pkgs.nil # nix language server
    pkgs.alejandra # nix formatter
  ];
}
