# adapted from https://blog.thalheim.io/2023/01/08/how-to-use-nixos-testing-framework-with-flakes/
test: {
  pkgs,
  modules,
  specialArgs,
  ...
}: let
  inherit (pkgs) lib;
  nixos-lib = import (pkgs.path + "/nixos/lib") {};
in
  (nixos-lib.runTest {
    hostPkgs = pkgs;
    defaults.documentation.enable = lib.mkDefault false;
    node.specialArgs =
      {
        inherit modules;
      }
      // specialArgs;
    imports = [
      test
    ];
  })
  .config
  .result
