{
  config,
  inputs,
  lib,
  pkgs,
  systemConfig,
  nixosModules,
  ...
}: let
  vms = {
    vm-gitlab-runner = {
      id = 3;
      name = "vm-gitlab-runner";
    };
  };
  overlayImage = "nix-store-overlay.img";
in {
  imports = [
    inputs.microvm.nixosModules.host
  ];

  systemd.network.netdevs."10-microvm".netdevConfig = {
    Kind = "bridge";
    Name = "microvm";
  };
  systemd.network.networks."10-microvm" = {
    matchConfig.Name = "microvm";
    networkConfig = {
      DHCPServer = true;
      IPv6SendRA = true;
    };
    addresses = [
      {
        Address = "10.0.0.1/24";
      }
      {
        Address = "fd12:3456:789a::1/64";
      }
    ];
    ipv6Prefixes = [
      {
        Prefix = "fd12:3456:789a::/64";
      }
    ];
  };
  # Attach all microvm interfaces to the bridge
  systemd.network.networks."11-microvm" = {
    matchConfig.Name = "vm-*";
    networkConfig.Bridge = "microvm";
  };
  # Allow inbound traffic for the DHCP server
  networking.firewall.allowedUDPPorts = [
    67
  ];
  # Use nat to allow microvms to access the internet
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "enp6s0";
    internalInterfaces = ["microvm"];
  };

  microvm.vms = {
    "${vms.vm-gitlab-runner.name}" = {
      specialArgs = {
        inherit inputs systemConfig;
      };

      config = {
        imports = [
          inputs.self.nixosModules.default
        ];

        networking.hostName = vms.vm-gitlab-runner.name;
        system.stateVersion = "25.11";

        microvm = {
          hypervisor = "cloud-hypervisor";
          vcpu = 8;
          mem = 1024 * 16; # 16 GiB

          vsock.cid = vms.vm-gitlab-runner.id;

          # Allow the microvm to write to the nix store
          writableStoreOverlay = "/nix/.rw-store";

          shares = [
            # Mount the host's nix store to save disk space
            {
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              tag = "ro-store";
              proto = "virtiofs";
            }
          ];
          volumes = [
            {
              image = overlayImage;
              mountPoint = "/nix/.rw-store";
              size = 1024 * 100; # 100 GiB
            }
            {
              image = "var.img";
              mountPoint = "/var";
              size = 1024 * 100; # 100 GiB
            }
            {
              image = "etc.img";
              mountPoint = "/etc";
              size = 1024 * 1; # 1 GiB
            }
          ];
          interfaces = [
            {
              type = "tap";
              id = "vm-net${toString vms.vm-gitlab-runner.id}";
              mac = "02:00:00:00:00:0${toString vms.vm-gitlab-runner.id}";
            }
          ];
        };

        systemd.network.enable = true;

        # Don't manage docker interfaces
        systemd.network.networks."19-docker" = {
          matchConfig.Name = "veth*";
          linkConfig = {
            Unmanaged = true;
          };
        };

        # Override conflicting options
        nix.gc.automatic = lib.mkForce false;
        nix.settings.auto-optimise-store = lib.mkForce false;
        nixpkgs.config = lib.mkForce {};

        # Services
        meenzen.hetzner.enable = true;
      };
    };
  };

  # Remove nix store overlay image after the microvm is stopped
  # see https://github.com/microvm-nix/microvm.nix/issues/210#issuecomment-1979680979
  systemd.services = {
    "microvm-rm-image-${vms.vm-gitlab-runner.name}" = {
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeScript "rm-image" ''
          #!${pkgs.runtimeShell}
          rm -f /var/lib/microvms/${vms.vm-gitlab-runner.name}/${overlayImage}
        '';
      };
    };

    "microvm@${vms.vm-gitlab-runner.name}" = {
      after = ["microvm-rm-image-${vms.vm-gitlab-runner.name}.service"];
      requires = ["microvm-rm-image-${vms.vm-gitlab-runner.name}.service"];
    };
  };
}
