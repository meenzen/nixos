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

    # Rust
    pkgs.rustup

    # Misc
    pkgs.hyperfine
    pkgs.glow
    pkgs.tokei
    pkgs.difftastic
    pkgs.terraform
    pkgs.devenv
  ];
}
