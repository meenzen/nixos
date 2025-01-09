{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    iperf3
    dnsutils # dig + nslookup
    ldns # drill (dig alternative)
    aria2 # download manager
    socat
    nmap
    ookla-speedtest
  ];

  # better traceroute
  programs.mtr.enable = true;
}
