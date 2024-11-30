{
  nixpkgs.config.permittedInsecurePackages = [
    # Legacy olm library is required for some matrix clients
    "olm-3.2.16"

    "dotnet-core-combined"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-7.0.410"
    "dotnet-sdk-wrapped-6.0.428"
    "dotnet-sdk-wrapped-7.0.410"
  ];
}
