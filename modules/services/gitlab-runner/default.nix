{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.services.gitlab-runner;
in {
  options.meenzen.services.gitlab-runner = {
    enable = lib.mkEnableOption "Enable GitLab Runner";
    enableHardwareAcceleration = lib.mkEnableOption "Enable hardware accelerated virtualization and rendering";
    image = lib.mkOption {
      type = lib.types.str;
      default = "alpine";
      description = "The docker image to use";
    };
    concurrency = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "The number of concurrent jobs to run";
    };
    cleanupSchedule = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "The schedule for cleaning up old data";
    };

    # Config files should contain at least these two variables:
    # `CI_SERVER_URL`
    # `CI_SERVER_TOKEN`
    nixRunnerConfigFile = lib.mkOption {
      type = lib.types.path;
      default = "";
    };
    dockerRunnerConfigFile = lib.mkOption {
      type = lib.types.path;
      default = "";
    };
    dockerPrivileged = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Run the docker runner in privileged mode";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernel.sysctl."net.ipv4.ip_forward" = true;
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = true;
    systemd.services.gitlab-runner.path = ["/run/wrappers"];

    virtualisation.docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = cfg.cleanupSchedule;
        flags = ["--all"];
      };
      daemon.settings = {
        # use a mirror that is not rate limited
        "registry-mirrors" = ["https://mirror.gcr.io"];
      };
    };
    networking.firewall.interfaces."docker+".allowedUDPPorts = [53 5353];
    networking.firewall.trustedInterfaces = ["docker0"];

    services.gitlab-runner = {
      enable = true;
      gracefulTimeout = "5min";
      gracefulTermination = true;

      settings = {
        concurrent = cfg.concurrency;
        checkInterval = 3;
      };

      clear-docker-cache = {
        enable = true;
        dates = cfg.cleanupSchedule;
        flags = ["prune"];
      };

      services = {
        nix = lib.mkIf (cfg.nixRunnerConfigFile != "") {
          authenticationTokenConfigFile = cfg.nixRunnerConfigFile;
          limit = cfg.concurrency;
          dockerImage = cfg.image;
          dockerVolumes = [
            "/nix/store:/nix/store:ro"
            "/nix/var/nix/db:/nix/var/nix/db:ro"
            "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
          ];
          registrationFlags = lib.mkIf cfg.enableHardwareAcceleration [
            "--docker-devices /dev/kvm"
            "--docker-devices /dev/dri"
          ];
          dockerDisableCache = true;
          preBuildScript = pkgs.writeScript "setup-container" ''
            mkdir -p -m 0755 /nix/var/log/nix/drvs
            mkdir -p -m 0755 /nix/var/nix/gcroots
            mkdir -p -m 0755 /nix/var/nix/profiles
            mkdir -p -m 0755 /nix/var/nix/temproots
            mkdir -p -m 0755 /nix/var/nix/userpool
            mkdir -p -m 1777 /nix/var/nix/gcroots/per-user
            mkdir -p -m 1777 /nix/var/nix/profiles/per-user
            mkdir -p -m 0755 /nix/var/nix/profiles/per-user/root
            mkdir -p -m 0700 "$HOME/.nix-defexpr"

            . ${pkgs.nix}/etc/profile.d/nix.sh

            ${pkgs.nix}/bin/nix-env -i ${lib.strings.concatStringsSep " " (with pkgs; [nix cacert git openssh coreutils bash])}

            ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixpkgs-unstable
            ${pkgs.nix}/bin/nix-channel --update nixpkgs
          '';
          environmentVariables = {
            ENV = "/etc/profile";
            USER = "root";
            NIX_REMOTE = "daemon";
            PATH = "/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin";
            NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
          };
        };

        docker = lib.mkIf (cfg.dockerRunnerConfigFile != "") {
          authenticationTokenConfigFile = cfg.dockerRunnerConfigFile;
          limit = cfg.concurrency;
          dockerImage = cfg.image;
          dockerPrivileged = cfg.dockerPrivileged;
          dockerVolumes = [
            "/var/run/docker.sock:/var/run/docker.sock"
          ];
          registrationFlags = lib.mkIf cfg.enableHardwareAcceleration [
            "--docker-devices /dev/kvm"
            "--docker-devices /dev/dri"
          ];
        };
      };
    };
  };
}
