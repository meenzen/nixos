{
  systemConfig,
  pkgs,
  ...
}: {
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

  # temporary workaround https://github.com/NixOS/nixpkgs/issues/456221#issuecomment-3452733065
  programs.ssh.package = pkgs.openssh_10_2;
}
