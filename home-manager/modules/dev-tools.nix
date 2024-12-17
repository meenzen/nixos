{
  pkgs,
  inputs,
  ...
}: let
  dotnet-combined =
    (with pkgs.dotnetCorePackages;
      combinePackages [
        sdk_9_0
        sdk_8_0
      ])
    .overrideAttrs (finalAttrs: previousAttrs: {
      # This is needed to install workload in $HOME
      # https://discourse.nixos.org/t/dotnet-maui-workload/20370/12

      postBuild =
        (previousAttrs.postBuild or '''')
        + ''
          for i in $out/sdk/*
          do
            i=$(basename $i)
            length=$(printf "%s" "$i" | wc -c)
            substring=$(printf "%s" "$i" | cut -c 1-$(expr $length - 2))
            i="$substring""00"
            mkdir -p $out/metadata/workloads/''${i/-*}
            touch $out/metadata/workloads/''${i/-*}/userlocal
          done
        '';
    });
in {
  home.sessionVariables = {
    DOTNET_ROOT = "${dotnet-combined}/share/dotnet";
    MSBUILDTERMINALLOGGER = "auto";
  };
  home.packages = with pkgs; [
    # Compilers
    dotnet-combined
    gcc

    # Rust
    rustup

    # Misc
    hyperfine
    glow
    tokei
    difftastic
    terraform
  ];
}
