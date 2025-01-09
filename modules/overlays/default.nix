{lib, ...}: {
  nixpkgs = {
    overlays = [
      # tokei: add support for razor files, see https://github.com/XAMPPRocky/tokei/pull/992
      (final: prev: {
        tokei = prev.tokei.overrideAttrs (oldAttrs: rec {
          version = "13.0.0-alpha.6";
          src = prev.fetchFromGitHub {
            owner = "XAMPPRocky";
            repo = "tokei";
            rev = "v${version}";
            sha256 = "sha256-dKDoGdZPKeXdY6seFYEwQZkn2RtcFPddu2DtIZrnXJI=";
          };
          cargoDeps = oldAttrs.cargoDeps.overrideAttrs (lib.const {
            name = "tokei-vendor.tar.gz";
            inherit src;
            outputHash = "sha256-ftAn9d50r07NrtFi0JJVeCy2q0ucfXmSg7T2zSTxJ30=";
          });
        });
      })

      # sudo: enable insults
      (final: prev: {sudo = prev.sudo.override {withInsults = true;};})
    ];
  };
}
