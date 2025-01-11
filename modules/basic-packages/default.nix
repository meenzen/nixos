{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    duf
    htop
    ncdu
  ];
}
