{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.mudblazor-docs;
in {
  options.meenzen.mudblazor-docs = {
    enable = lib.mkEnableOption "Enable MudBlazor Docs";
  };

  imports = [
    ./v6.nix
  ];

  config = lib.mkIf cfg.enable {
    meenzen.mudblazor-docs.v6.enable = true;
  };
}
