{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    pkgs.git
    pkgs.vim
    pkgs.wget
    pkgs.duf
    pkgs.htop
    pkgs.ncdu
    pkgs.uutils-coreutils-noprefix
  ];
}
