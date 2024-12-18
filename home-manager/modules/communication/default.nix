{pkgs, ...}: {
  home.packages = with pkgs; [
    discord
    teamspeak_client
    mumble
    beeper
  ];
}
