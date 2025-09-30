{
  pkgs,
  inputs,
  ...
}: let
  dotnet = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnetCorePackages.sdk_10_0-bin
    pkgs.dotnetCorePackages.sdk_9_0
  ];
in {
  home.sessionVariables = {
    DOTNET_ROOT = "${dotnet}/share/dotnet";
    MSBUILDTERMINALLOGGER = "auto";
  };
  home.packages = [
    # Compilers
    dotnet
    pkgs.gcc

    # Misc
    pkgs.hyperfine
    pkgs.glow
    pkgs.tokei
    pkgs.difftastic
    pkgs.terraform
    pkgs.devenv
    pkgs.gh
    pkgs.glab
    pkgs.nixpkgs-review
  ];
}
