{
  nixpkgs.config.permittedInsecurePackages = [
    # Temporary workaround, remove this soon: https://github.com/NixOS/nixpkgs/issues/535580#issuecomment-4809489104
    "pnpm-10.29.2"
  ];
}
