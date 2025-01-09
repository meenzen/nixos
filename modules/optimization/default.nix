{
  zramSwap.enable = true;
  boot.kernel.sysctl = {
    "vm.swappiness" = 60;
  };
}
