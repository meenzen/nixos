{pkgs, ...}: {
  home.packages = [
    # build failure
    pkgs.vesktop
    pkgs.mumble
    #pkgs.teamspeak_client
  ];
}
