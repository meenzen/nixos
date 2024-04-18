{pkgs, ...}: {
  home.packages = with pkgs; [
    nix-output-monitor # nom
    nix-tree
    nil # nix language server
    alejandra # nix formatter
  ];
}
