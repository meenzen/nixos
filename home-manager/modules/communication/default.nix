{pkgs, ...}: {
  home.packages = [
    pkgs.discord
    pkgs.teamspeak_client
    pkgs.mumble
    pkgs.beeper
  ];
}
