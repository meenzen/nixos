{
  nixpkgs.config.permittedInsecurePackages = [
    # Legacy olm library is required for some matrix clients
    "olm-3.2.16"
  ];
}
