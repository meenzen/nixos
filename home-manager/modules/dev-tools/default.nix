{
  pkgs,
  inputs,
  ...
}: let
  dotnet = pkgs.dotnetCorePackages.sdk_9_0;
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
    # https://github.com/NixOS/nixpkgs/issues/420134
    #pkgs.devenv
    pkgs.gh
    pkgs.glab
    pkgs.nixpkgs-review
  ];
}
