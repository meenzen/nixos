{
  imports = [
    ./agenix
    ./cleanup
    ./hetzner
    ./locale
    ./nginx
    ./nix
    ./oci-containers
    ./openssh
    ./optimization
    ./postgresql
    ./system-packages
  ];

  networking.firewall.enable = true;
}
