{lib, ...}: {
  nixpkgs = {
    overlays = [
      # tokei: add support for razor files, see https://github.com/XAMPPRocky/tokei/pull/992
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

      # sudo: enable insults
      (final: prev: {sudo = prev.sudo.override {withInsults = true;};})
    ];
  };
}
