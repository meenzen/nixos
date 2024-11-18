{pkgs, ...}: {
  # YubiKey support
  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  # Smartcard support
  services.pcscd.enable = true;

  # Management GUI
  environment.systemPackages = with pkgs; [
    yubioath-flutter
  ];
}
