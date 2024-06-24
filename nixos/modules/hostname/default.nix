{systemConfig, ...}: {
  networking.hostName = systemConfig.hostName;
}
