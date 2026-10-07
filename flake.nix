{
  description = "Personal NixOS configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-review.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-review.url = "github:nixos/nixpkgs?ref=refs/pull/000000/head";

    # Determinate Nix
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # Helper Libraries
    nixos-hardware.url = "github:nixos/nixos-hardware";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Deployment Tools
    colmena.url = "github:nix-community/colmena";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Customization
    stylix.url = "github:nix-community/stylix";

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
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Miscellaneous
    nixos-matrix-modules.url = "github:D4ndellion/nixos-matrix-modules";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (_: let
      systemConfig = {
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
      pkgs-stable = import inputs.nixpkgs-stable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      pkgs-review = import inputs.nixpkgs-review {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      specialArgs = {
        inherit inputs pkgs-stable pkgs-review systemConfig;
      };
    in {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks-nix.flakeModule
      ];
      flake = {
        nixosModules = rec {
          meenzen = import ./modules;
          default = meenzen;
        };

        lib = {
          mkSystem = systemModule:
            inputs.nixpkgs.lib.nixosSystem {
              specialArgs = specialArgs;
              modules = [
                self.nixosModules.default
                systemModule
              ];
            };

          mkServer = targetHost: systemModule: {
            deployment.targetHost = targetHost;
            imports = [systemModule];
          };
        };

        nixosConfigurations = let
          mkSystem = self.lib.mkSystem;
        in
          {
            framework = mkSystem ./systems/framework/configuration.nix;
            install-iso = mkSystem ./systems/install-iso/configuration.nix;
            the-machine = mkSystem ./systems/the-machine/configuration.nix;
            vm = mkSystem ./systems/vm/configuration.nix;
            wsl = mkSystem ./systems/wsl/configuration.nix;
          }
          // self.outputs.colmenaHive.nodes;

        # See https://github.com/zhaofengli/colmena/pull/228
        colmenaHive = inputs.colmena.lib.makeHive self.outputs.colmena;

        colmena = let
          mkServer = self.lib.mkServer;
        in {
          meta = {
            nixpkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
            };
            specialArgs = specialArgs;
          };

          defaults = {...}: {
            imports = [
              self.nixosModules.meenzen
            ];
            deployment = {
              buildOnTarget = true;
              targetUser = "meenzens";
            };
          };

          neon = mkServer "neon.mnzn.dev" ./systems/neon/configuration.nix;
          lithium = mkServer "lithium.localdomain" ./systems/lithium/configuration.nix;
        };
      };
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      perSystem = {
        config,
        inputs',
        pkgs,
        ...
      }: {
        treefmt = {
          # pre-commit runs treefmt, this would run it a second time
          flakeCheck = false;
          programs = {
            alejandra.enable = true;
            statix = {
              enable = true;
              # use statix.toml instead of the default configuration
              disabled-lints = (builtins.fromTOML (builtins.readFile ./statix.toml)).disabled;
            };
            shellcheck = {
              enable = true;
              includes = ["bin/*"];
              external-sources = true;
              source-path = "SCRIPTDIR";
            };
            shfmt = {
              enable = true;
              includes = ["bin/*"];
              # Don't rewrite quoting style, only formatting
              simplify = false;
            };
            # Configured in .github/actionlint.yaml
            actionlint.enable = true;
          };
          settings.formatter = {
            # reformat nix files after they've been changed by statix
            statix.priority = 0;
            alejandra.priority = 1;
          };
        };

        pre-commit.settings.hooks = {
          treefmt.enable = true;
          deadnix.enable = true;
          # treefmt only runs 'statix fix', this catches lints that can't be fixed automatically
          statix.enable = true;
          # Configured in typos.toml, check-only because auto-fixes can break config values
          typos.enable = true;
          # Configured in .editorconfig
          editorconfig-checker.enable = true;
        };

        checks = let
          modules = ./modules;
          args = {
            inherit pkgs modules specialArgs;
          };
        in {
          glitchtip = import ./tests/glitchtip.nix args;
        };
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.git
            pkgs.nil
            pkgs.nom
            pkgs.nvd
            pkgs.uutils-coreutils-noprefix
            pkgs.colmena
            inputs'.agenix.packages.default
            config.pre-commit.settings.package
          ];

          # treefmt and its formatters, plus the tools used by the git hooks
          inputsFrom = [config.treefmt.build.devShell];
          packages = config.pre-commit.settings.enabledPackages;

          shellHook = ''
            ${config.pre-commit.installationScript}
            set -euo pipefail
            source "${./bin}/lib.sh"
            print_divider_basic
            echo "$(nix --version)"
            echo "$(git --version)"
            echo "$(nil --version)"
            echo "nom $(nom version)"
            echo "$(nvd --version)"
            echo "$(alejandra --version)"
            echo "statix $(which statix | grep -oP 'statix-\K[^/]+(?=/bin)')"
            echo "$(deadnix --version)"
            echo "shellcheck $(shellcheck --version | grep -oP '^version: \K.*')"
            echo "$(treefmt --version)"
            echo "$(pre-commit --version)"
            echo "$(colmena --version)"
            echo "$(agenix --help | tail -n 3)"
            print_divider_basic
          '';
        };
      };
    });
}
