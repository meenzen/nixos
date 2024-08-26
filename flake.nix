{
  description = "Personal NixOS configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-meenzen.url = "github:meenzen/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    flake-utils.url = "github:numtide/flake-utils";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wezterm = {
      url = "github:wez/wezterm/main?dir=nix";
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
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-meenzen,
    nixos-hardware,
    flake-utils,
    home-manager,
    plasma-manager,
    stylix,
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

    defaultConfig = {
      systemModule = ./nixos/systems/vm/configuration.nix;
      extraModules = [];
      hostName = "nixos";
      user = {
        username = "meenzens";
        fullName = "Samuel Meenzen";
        email = "samuel@meenzen.net";
        initialPassword = "password";
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMa9vjZasAelcVAdtLa+vI0dYvx4hba2z6z+J+u39irB meenzens@framework"
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDOHTWbt687mGfFsdxrgSyCtyrb547mw5+SL3FdAT5KeAAAABHNzaDo= YubiKey C"
        ];
        extraGroups = ["networkmanager" "wheel" "docker" "vboxusers" "input"];
      };
      additionalPinnedApps = [];
      additionalShownSystemTrayItems = [];
    };

    mkSystem = systemConfig:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs systemConfig;
        };
        modules =
          [
            systemConfig.systemModule
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = {
                  inherit inputs outputs systemConfig;
                };
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users = {
                  meenzens = import ./home-manager/home.nix;
                };
                sharedModules = [plasma-manager.homeManagerModules.plasma-manager];
              };
            }
            stylix.nixosModules.stylix
          ]
          ++ systemConfig.extraModules;
      };
  in {
    inherit (devShells) devShells;

    nixosConfigurations = {
      the-machine = mkSystem (nixpkgs.lib.recursiveUpdate defaultConfig {
        systemModule = ./nixos/systems/the-machine/configuration.nix;
        hostName = "the-machine";
        additionalPinnedApps = [
          "applications:steam.desktop"
          "applications:com.heroicgameslauncher.hgl.desktop"
        ];
      });
      framework = mkSystem (nixpkgs.lib.recursiveUpdate defaultConfig {
        systemModule = ./nixos/systems/framework/configuration.nix;
        hostName = "framework";
        additionalPinnedApps = [
          "applications:google-chrome.desktop"
          "applications:rider.desktop"
        ];
        additionalShownSystemTrayItems = [
          "org.kde.plasma.battery"
        ];
      });
      vm = mkSystem (nixpkgs.lib.recursiveUpdate defaultConfig {
        hostName = "vm";
      });
      install-iso = mkSystem (nixpkgs.lib.recursiveUpdate defaultConfig {
        systemModule = ./nixos/systems/install-iso/configuration.nix;
        extraModules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
        ];
        hostName = "install-iso";
      });
    };
  };
}
