{
  config,
  lib,
  osConfig,
  ...
}: {
  options.meenzen.virt-manager.enable =
    lib.mkEnableOption "virt-manager connections"
    // {default = osConfig.meenzen.virt-manager.enable;};

  config = lib.mkIf config.meenzen.virt-manager.enable {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
