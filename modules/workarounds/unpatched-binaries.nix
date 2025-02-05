{
  lib,
  pkgs,
  config,
  ...
}: {
  # https://nix.dev/guides/faq.html#how-to-run-non-nix-executables
  programs.nix-ld = lib.mkIf config.meenzen.desktop.enable {
    enable = true;
    libraries = [
      # Add any missing dynamic libraries for unpackaged programs
      # here, NOT in environment.systemPackages
      pkgs.libsecret
    ];
  };
}
