{
  pkgs,
  lib,
  ...
}: {
  environment.variables = {
    LD_LIBRARY_PATH = lib.makeLibraryPath [
      pkgs.fontconfig
    ];
  };
}
