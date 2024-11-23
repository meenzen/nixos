{
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 20;
      memtest86.enable = true;
      netbootxyz.enable = true;
      edk2-uefi-shell.enable = true;
    };
  };
}
