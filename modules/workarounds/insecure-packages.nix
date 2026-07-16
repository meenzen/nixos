{
  nixpkgs.config.permittedInsecurePackages = [
    # temporary workaround for Vesktop
    "electron-40.10.5"
  ];
}
