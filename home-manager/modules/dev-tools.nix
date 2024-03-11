{pkgs, ...}: {
  home.packages = with pkgs; [
    vscode
    kate
    jetbrains.rider
    rustup
    tokei
    glow
    (with dotnetCorePackages;
      combinePackages [
        sdk_8_0
        sdk_7_0
        sdk_6_0
      ])
  ];
}
