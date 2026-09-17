{
  osConfig,
  lib,
  ...
}: {
  config = lib.mkIf osConfig.meenzen.virt-manager.enable {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
