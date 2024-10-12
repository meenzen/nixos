{
  inputs,
  outputs,
  systemConfig,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        extraSpecialArgs = {
          inherit inputs outputs systemConfig;
        };
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users = {
          meenzens = import systemConfig.homeManagerModule;
        };
        sharedModules = [inputs.plasma-manager.homeManagerModules.plasma-manager];
      };
    }
  ];
}
