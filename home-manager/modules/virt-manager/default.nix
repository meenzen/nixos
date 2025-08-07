{
  config,
  osConfig,
  lib,
  pkgs,
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
