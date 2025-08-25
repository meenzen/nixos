{
  config,
  lib,
  pkgs,
  systemConfig,
  ...
}: let
  cfg = config.meenzen.virt-manager;
in {
  options.meenzen.virt-manager = {
    enable = lib.mkEnableOption "Enable virt-manager";
  };

  config = lib.mkIf cfg.enable {
    programs.virt-manager.enable = true;
    users.groups = {
      libvirtd.members = [systemConfig.user.username];
      kvm.members = [systemConfig.user.username];
    };
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.packages = [pkgs.OVMFFull.fd];
      };
    };
    virtualisation.spiceUSBRedirection.enable = true;
    networking.firewall.trustedInterfaces = [
      "virbr0"
    ];
  };
}
