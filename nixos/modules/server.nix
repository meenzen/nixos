{
  imports = [
    ./cleanup
    ./locale
    ./nix
    ./openssh
    ./system-packages
  ];

  networking.firewall.enable = true;
}
