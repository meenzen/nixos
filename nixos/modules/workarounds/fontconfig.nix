{pkgs, ...}: {
  environment.variables = {
    LD_LIBRARY_PATH = with pkgs;
      lib.makeLibraryPath [
        fontconfig
      ];
  };
}
