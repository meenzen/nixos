{
  config,
  lib,
  ...
}: let
  cfg = config.meenzen.libvirt;
in {
  options.meenzen.libvirt = {
    enable = lib.mkEnableOption "Enable libvirt for local or remote management with virt-manager";
  };

  config = lib.mkIf cfg.enable {
    users.groups = {
      libvirtd.members = [config.meenzen.user.username];
      kvm.members = [config.meenzen.user.username];
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
