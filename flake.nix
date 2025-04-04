{
  description = "Personal NixOS configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    # Helper Libraries
    nixos-hardware.url = "github:nixos/nixos-hardware";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      # current nixpkgs is not compatible
      # inputs.nixpkgs.follows = "nixpkgs";
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
    stylix.url = "github:danth/stylix?ref=b00c9f46ae6c27074d24d2db390f0ac5ebcc329f"; # see https://github.com/danth/stylix/issues/835
    nixvim.url = "github:nix-community/nixvim";
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

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (top @ {
      config,
      withSystem,
      moduleWithSystem,
      ...
    }: let
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
          extraGroups = [];
        };
      };
    in {
      imports = [];
      flake = {
        nixosConfigurations = let
          mkSystem = systemModule: let
            systemConfig = defaultConfig;
            pkgs-stable = import inputs.nixpkgs-stable {
              system = "x86_64-linux";
            };
          in
            inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit inputs systemConfig pkgs-stable;
              };
              modules = [
                ./modules
                systemModule
              ];
            };
        in {
          framework = mkSystem ./systems/framework/configuration.nix;
          install-iso = mkSystem ./systems/install-iso/configuration.nix;
          neon = mkSystem ./systems/neon/configuration.nix;
          the-machine = mkSystem ./systems/the-machine/configuration.nix;
          vm = mkSystem ./systems/vm/configuration.nix;
          wsl = mkSystem ./systems/wsl/configuration.nix;
        };

        # See https://github.com/zhaofengli/colmena/pull/228
        colmenaHive = inputs.colmena.lib.makeHive self.outputs.colmena;

        colmena = let
          mkServer = targetHost: systemModule: {
            deployment.targetHost = targetHost;
            imports = [systemModule];
          };
        in {
          meta = {
            nixpkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
            };
            specialArgs = {
              inherit inputs;
              systemConfig = defaultConfig;
            };
          };

          defaults = {pkgs, ...}: {
            imports = [
              ./modules
            ];
            deployment.buildOnTarget = true;
          };

          neon = mkServer "neon.mnzn.dev" ./systems/neon/configuration.nix;
        };
      };
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        lib,
        system,
        ...
      }: {
        formatter = pkgs.alejandra;
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.git
            pkgs.nixVersions.stable
            pkgs.nil
            pkgs.alejandra
            pkgs.uutils-coreutils-noprefix
            inputs'.colmena.packages.colmena
            inputs'.agenix.packages.default
          ];
          shellHook = ''
            echo ""
            echo "$(git --version)"
            echo "$(nil --version)"
            echo "$(alejandra --version)"
            echo ""
          '';
        };
      };
    });
}
