{systemConfig, ...}: {
  programs.adb.enable = true;
  users.users."${systemConfig.user.username}".extraGroups = ["adbusers"];
}
