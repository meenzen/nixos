{
  lib,
  pkgs,
  pkgs-review,
  ...
}: {
  nixpkgs.overlays = [
    # tokei: use the latest alpha since there hasn't been a stable release since 2021
    # https://github.com/XAMPPRocky/tokei/issues/911
    (final: prev: {
      tokei = prev.tokei.overrideAttrs (oldAttrs: rec {
        version = "13.0.0-alpha.8";
        src = prev.fetchFromGitHub {
          owner = "XAMPPRocky";
          repo = "tokei";
          rev = "v${version}";
          sha256 = "sha256-jCI9VM3y76RI65E5UGuAPuPkDRTMyi+ydx64JWHcGfE=";
        };
        cargoDeps = final.rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-LzlyrKaRjUo6JnVLQnHidtI4OWa+GrhAc4D8RkL+nmQ=";
        };
      });
    })

    (final: prev: {
      # https://github.com/NixOS/nixpkgs/pull/449133
      intel-graphics-compiler = pkgs-review.intel-graphics-compiler;
      # https://github.com/NixOS/nixpkgs/pull/449515
      fw-ectool = pkgs-review.fw-ectool;
      # https://github.com/NixOS/nixpkgs/pull/449551
      ltrace = prev.ltrace.overrideAttrs (oldAttrs: {
        patches =
          (oldAttrs.patches or [])
          ++ [
            (pkgs.fetchpatch {
              name = "ltrace-0.7.3-print-test-pie.patch";
              url = "https://raw.githubusercontent.com/gentoo/gentoo/refs/heads/master/dev-debug/ltrace/files/ltrace-0.7.3-print-test-pie.patch";
              hash = "sha256-rUafTv13a4vS/yNIVRMbm5zwWTVTqMmFgmnS/XtPfdE=";
            })
          ];
      });
    })
  ];
}
