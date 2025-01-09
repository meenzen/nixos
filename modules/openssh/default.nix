{systemConfig, ...}: {
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = systemConfig.user.authorizedKeys;

  services.fail2ban = {
    enable = true;
    bantime = "1h";
    bantime-increment.enable = true;
    ignoreIP = [
      # Whitelist Private Networks
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ];
  };
}
