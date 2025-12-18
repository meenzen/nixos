{
  pkgs,
  lib,
  inputs,
  ...
}: let
  dotnet = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnetCorePackages.sdk_10_0
    pkgs.dotnetCorePackages.sdk_9_0
    pkgs.dotnetCorePackages.sdk_8_0
  ];
  dotnetRoot = "${dotnet}/share/dotnet";
in {
  home.sessionVariables = {
    DOTNET_ROOT = dotnetRoot;
    DOTNET_ROOT_X64 = dotnetRoot;

    # General reliability
    DOTNET_MULTILEVEL_LOOKUP = "0";
    DOTNET_CLI_HOME = "$HOME/.dotnet";
    NUGET_PACKAGES = "$HOME/.nuget/packages";

    # Shut up, Microsoft
    DOTNET_NOLOGO = "1";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };

  # Just to be sure
  home.activation.ensureDotnetDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p \
      "$HOME/.dotnet" \
      "$HOME/.nuget/packages" \
      "$HOME/.nuget/NuGet" \
      "$HOME/.local/share/NuGet"
  '';

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
    pkgs.csharprepl

    # Kubernetes
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.argocd-autopilot
    (pkgs.callPackage ./cloudfleet.nix {})
  ];
}
