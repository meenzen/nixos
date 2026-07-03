{
  zramSwap.enable = true;
  boot.kernel.sysctl = {
    "vm.swappiness" = 60;
  };

  # Don't keep too many logs around
  services.journald.extraConfig = ''
    MaxRetentionSec=7day
    SystemMaxUse=1G
  '';
}
