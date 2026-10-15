{
  config,
  lib,
  systemConfig,
  ...
}: let
  cfg = config.meenzen.libvirt;
in {
  options.meenzen.libvirt = {
    enable = lib.mkEnableOption "Enable libvirt for local or remote management with virt-manager";
  };

  config = lib.mkIf cfg.enable {
    users.groups = {
      libvirtd.members = [systemConfig.user.username];
      kvm.members = [systemConfig.user.username];
    };
    virtualisation.libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    networking.firewall.trustedInterfaces = [
      "virbr0"
    ];
  };
}
