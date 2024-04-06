{pkgs, ...}: let
  dotnet-combined =
    (with pkgs.dotnetCorePackages;
      combinePackages [
        sdk_8_0
        sdk_7_0
        sdk_6_0
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
    DOTNET_ROOT = "${dotnet-combined}";
  };
  home.packages = with pkgs; [
    glow
    tokei

    # Compilers
    dotnet-combined
    gcc

    # Editors
    vscode
    kdePackages.kate

    # JetBrains IDEs don't work correctly, plugins are broken.
    #jetbrains.rider
    #jetbrains.rust-rover
    #jetbrains.idea-ultimate
    #jetbrains.webstorm
    jetbrains-toolbox # install IDEs from toolbox manually for now

    # Rust
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt

    # Misc
    hyperfine
  ];
}
