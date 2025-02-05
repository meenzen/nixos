{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.iperf3
    pkgs.dnsutils # dig + nslookup
    pkgs.ldns # drill (dig alternative)
    pkgs.aria2 # download manager
    pkgs.socat
    pkgs.nmap
    pkgs.ookla-speedtest
  ];

  # better traceroute
  programs.mtr.enable = true;
}
