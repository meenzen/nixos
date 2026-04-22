{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.meenzen.desktop.enable {
    # Fix JetBrains Toolbox, see https://github.com/NixOS/nixpkgs/issues/240444#issuecomment-4295521335
    programs.nix-ld = {
      enable = true;
      libraries =
        (pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs pkgs)
        ++ (with pkgs; [
          libsecret
        ]);
    };
  };
}
