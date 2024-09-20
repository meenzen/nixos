{systemConfig, ...}: {
  users.users."${systemConfig.user.username}".extraGroups = ["docker"];

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      # use a mirror that is not rate limited
      "registry-mirrors" = ["https://mirror.gcr.io"];

      # custom address pools to avoid conflicts with the corporate network
      "bip" = "192.168.180.1/24";
      "default-address-pools" = [
        {
          base = "192.168.181.0/24";
          size = 24;
        }
        {
          base = "192.168.182.0/24";
          size = 24;
        }
        {
          base = "192.168.183.0/24";
          size = 24;
        }
        {
          base = "192.168.184.0/24";
          size = 24;
        }
        {
          base = "192.168.185.0/24";
          size = 24;
        }
        {
          base = "192.168.186.0/24";
          size = 24;
        }
        {
          base = "192.168.187.0/24";
          size = 24;
        }
        {
          base = "192.168.188.0/24";
          size = 24;
        }
        {
          base = "192.168.189.0/24";
          size = 24;
        }
      ];
    };
  };
}
