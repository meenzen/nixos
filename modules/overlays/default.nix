{
  lib,
  pkgs,
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

    # update https://github.com/NixOS/nixpkgs/pull/448969
    (final: prev: {
      argocd-autopilot = prev.argocd-autopilot.overrideAttrs (oldAttrs: rec {
        version = "0.4.20";
        src = prev.fetchFromGitHub {
          owner = "argoproj-labs";
          repo = "argocd-autopilot";
          rev = "v${version}";
          sha256 = "sha256-JLh41ZWiDcDrUtd8d+Ak5TFca4L6VHzUguS55P9lmj0=";
        };
        vendorHash = "sha256-Ur0BfIg4lZakjx01UOL4n5/O1yjTJJcGuDxWVDqUOyY=";
      });
    })
  ];
}
