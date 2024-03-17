{pkgs, ...}: {
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Docker
  virtualisation.docker.enable = true;

  # udev rules
  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];
}
