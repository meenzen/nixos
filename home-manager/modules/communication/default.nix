{pkgs, ...}: {
  home.packages = [
    pkgs.vesktop
    pkgs.mumble
    #pkgs.teamspeak_client
  ];
}
