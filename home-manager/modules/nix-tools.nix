{pkgs, ...}: {
  home.packages = with pkgs; [
    # provides the command `nom` works just like `nix` with more details log output
    nix-output-monitor
    nix-tree
    nil # nix language server
    alejandra # nix formatter
  ];
}
