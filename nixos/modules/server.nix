{
  imports = [
    ./agenix
    ./cleanup
    ./hetzner
    ./locale
    ./mastodon
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
