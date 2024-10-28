{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    mtr # better traceroute
    iperf3
    dnsutils # dig + nslookup
    ldns # drill (dig alternative)
    aria2 # download manager
    socat
    nmap
    ookla-speedtest
  ];
}
