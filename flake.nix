{
  description = "Personal NixOS configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-meenzen.url = "github:meenzen/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    flake-utils.url = "github:numtide/flake-utils";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Gaming
    nix-citizen.url = "github:LovingMelody/nix-citizen";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-citizen.inputs.nix-gaming.follows = "nix-gaming";
    protontweaks.url = "github:rain-cafe/protontweaks/main";
    protontweaks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-meenzen,
    nixos-hardware,
    flake-utils,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;

    devShells =
      flake-utils.lib.eachDefaultSystem
      (
        system: let
          pkgs = import nixpkgs {
            inherit system;
          };
        in {
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              git
              nixFlakes
              nil
              alejandra
            ];
            shellHook = ''
              echo ""
              echo "$(git --version)"
              echo "$(nil --version)"
              echo "$(alejandra --version)"
              echo ""
            '';
          };
        }
      );

    home-manager-config = {
      extraSpecialArgs = {inherit inputs outputs;};
      useUserPackages = true;
      users = {
        meenzens = import ./home-manager/home.nix;
      };
    };
  in {
    inherit (devShells) devShells;

    nixosConfigurations = {
      the-machine = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nixos/systems/the-machine/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = home-manager-config;
          }
        ];
      };

      framework = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nixos/systems/framework/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = home-manager-config;
          }
        ];
      };
    };
  };
}
