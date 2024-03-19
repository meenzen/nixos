{pkgs, ...}: {
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Docker
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      # use a mirror that is not rate limited
      "registry-mirrors" = ["https://mirror.gcr.io"];

      # custom address pools to avoid conflicts with the corporate network
      "default-address-pools" = [
        {
          base = "192.168.180.0/24";
          size = 24;
        }
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

  # udev rules
  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];
}
