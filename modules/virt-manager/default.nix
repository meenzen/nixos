{
  config,
  lib,
  ...
}: let
  cfg = config.meenzen.virt-manager;
in {
  options.meenzen.virt-manager = {
    enable = lib.mkEnableOption "virt-manager";
  };

  config = lib.mkIf cfg.enable {
    meenzen.libvirt.enable = true;
    programs.virt-manager.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
  };
}
