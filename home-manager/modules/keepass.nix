{pkgs, ...}: {
  home.packages = with pkgs; [
    keepass
    keepass-keetraytotp
  ];
}
