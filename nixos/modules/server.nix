{
  imports = [
    ./agenix
    ./cleanup
    ./hetzner
    ./locale
    ./mastodon
    ./matrix
    ./networking-tools
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
