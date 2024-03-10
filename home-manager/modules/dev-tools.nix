{pkgs, ...}: {
  home.packages = with pkgs; [
    vscode
    kate
    jetbrains.rider
    rustup
    tokei
    glow
  ];
}
