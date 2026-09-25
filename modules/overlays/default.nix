_: {
  nixpkgs.overlays = [
    (_: prev: {
      gamescope = prev.gamescope.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            # Fixes artifacting on NVIDIA by forcing contiguous scanout allocations via GBM
            # https://github.com/antheas/gamescope/commit/fa6f7f2503c2e773acf818ad688ddd1db73df3a0
            ./gamescope-nvidia-scanout.patch
          ];
      });
    })
  ];
}
