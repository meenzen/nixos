{
  description = "Personal NixOS configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-meenzen.url = "github:meenzen/nixpkgs/nixos-unstable";

    # Helper Libraries
    nixos-hardware.url = "github:nixos/nixos-hardware";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Customization
    stylix.url = "github:danth/stylix";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Gaming
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-citizen = {
      url = "github:LovingMelody/nix-citizen";
      inputs.nix-gaming.follows = "nix-gaming";
    };
    protontweaks = {
      url = "github:rain-cafe/protontweaks/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Other Programs
    authentik-nix.url = "github:nix-community/authentik-nix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    colmena,
    agenix,
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
              nixVersions.stable
              nil
              alejandra
              colmena.packages."${system}".colmena
              agenix.packages."${system}".default
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

    defaultConfig = {
      user = {
        username = "meenzens";
        fullName = "Samuel Meenzen";
        email = "samuel@meenzen.net";
        initialPassword = "password";
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMa9vjZasAelcVAdtLa+vI0dYvx4hba2z6z+J+u39irB meenzens@framework"
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDOHTWbt687mGfFsdxrgSyCtyrb547mw5+SL3FdAT5KeAAAABHNzaDo= YubiKey C"
        ];
        extraGroups = ["networkmanager" "wheel" "input"];
      };
    };

    mkSystem = systemModule: let
      systemConfig = defaultConfig;
    in
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs systemConfig;
        };
        modules = [
          systemModule
        ];
      };
  in {
    inherit (devShells) devShells;

    nixosConfigurations = {
      the-machine = mkSystem ./nixos/systems/the-machine/configuration.nix;
      framework = mkSystem ./nixos/systems/framework/configuration.nix;
      vm = mkSystem ./nixos/systems/vm/configuration.nix;
      wsl = mkSystem ./nixos/systems/wsl/configuration.nix;
      install-iso = mkSystem ./nixos/systems/install-iso/configuration.nix;

      # nixos-install --flake github:meenzen/nixos#neon
      neon = mkSystem ./nixos/systems/neon/configuration.nix;
    };

    # See https://github.com/zhaofengli/colmena/pull/228
    colmenaHive = colmena.lib.makeHive self.outputs.colmena;

    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
        };
        specialArgs = {
          inherit inputs outputs;
          systemConfig = defaultConfig;
        };
      };

      defaults = {pkgs, ...}: {
        imports = [
          ./nixos/modules
        ];
      };

      neon = {
        deployment.targetHost = "neon.mnzn.dev";
        deployment.buildOnTarget = true;
        imports = [
          ./nixos/systems/neon/configuration.nix
        ];
      };
    };
  };
}
