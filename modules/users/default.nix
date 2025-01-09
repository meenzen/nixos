{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}: {
  users.users = {
    "${systemConfig.user.username}" = {
      isNormalUser = true;
      initialPassword = systemConfig.user.initialPassword;
      openssh.authorizedKeys.keys = systemConfig.user.authorizedKeys;
      description = systemConfig.user.fullName;
      extraGroups = systemConfig.user.extraGroups;
    };
  };
}
