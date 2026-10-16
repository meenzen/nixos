{
  config,
  lib,
  pkgs,
  secrets,
  ...
}: let
  cfg = config.meenzen.services.forgejo-runner;
  nix = config.nix.package;
  ciPackages = with pkgs; [nix cacert git openssh coreutils bash direnv nix-direnv devenv];
  setup-nix-script = pkgs.writeScript "setup-nix" ''
    mkdir -p -m 0755 /nix/var/log/nix/drvs
    mkdir -p -m 0755 /nix/var/nix/gcroots
    mkdir -p -m 0755 /nix/var/nix/profiles
    mkdir -p -m 0755 /nix/var/nix/temproots
    mkdir -p -m 0755 /nix/var/nix/userpool
    mkdir -p -m 1777 /nix/var/nix/gcroots/per-user
    mkdir -p -m 1777 /nix/var/nix/profiles/per-user
    mkdir -p -m 0755 /nix/var/nix/profiles/per-user/root
    mkdir -p -m 0700 "$HOME/.nix-defexpr"

    export NIX_REMOTE=daemon
    echo "NIX_REMOTE=daemon" >> $FORGEJO_ENV
    echo "NIX_SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt" >> $FORGEJO_ENV
    echo "/nix/var/nix/profiles/default/bin" >> $FORGEJO_PATH
    echo "/nix/var/nix/profiles/default/sbin" >> $FORGEJO_PATH
    echo "/bin" >> $FORGEJO_PATH
    echo "/sbin" >> $FORGEJO_PATH
    echo "/usr/bin" >> $FORGEJO_PATH
    echo "/usr/sbin" >> $FORGEJO_PATH

    . ${nix}/etc/profile.d/nix.sh

    ${nix}/bin/nix-env -i ${lib.strings.concatStringsSep " " ciPackages}
  '';
in {
  options.meenzen.services.forgejo-runner = {
    enable = lib.mkEnableOption "Enable Forgejo Runner";
    uuid = lib.mkOption {
      type = lib.types.str;
      example = "c9e50be9-a7c3-4aee-ba35-624c4ff8c519";
      description = "The UUID of the runner, the matching token is read from the forgejoRunnerToken secret";
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
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      forgejoRunnerToken = {
        file = "${secrets}/forgejoRunnerToken.age";
        restartUnits = ["forgejo-runner-default.service"];
      };
    };

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

        # ipv6 support
        fixed-cidr-v6 = "fd00::/80";
        ipv6 = true;
      };
    };
    networking.firewall.interfaces."docker+".allowedUDPPorts = [53 5353];
    networking.firewall.trustedInterfaces = ["docker0" "br-+"];

    services.forgejo-runner = {
      package = pkgs.forgejo-runner;
      instances.default = {
        enable = true;
        secrets.server.connections.default.token_url = config.age.secrets.forgejoRunnerToken.path;
        settings = {
          server.connections.default = {
            url = "https://${config.meenzen.services.forgejo.domain}/";
            inherit (cfg) uuid;
          };
          runner = {
            capacity = cfg.concurrency;
            labels = [
              "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
              "ubuntu-24.04:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
              "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
              "nixos:docker://ghcr.io/catthehacker/ubuntu:act-latest"
            ];
          };
          container = {
            enable_ipv6 = true;
            docker_host = "automount";
            options = lib.strings.concatStringsSep " " [
              # Native Nix support
              "--volume /nix/store:/nix/store:ro"
              "--volume /nix/var/nix/db:/nix/var/nix/db:ro"
              "--volume /nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
              "--volume /nix/var/determinate/determinate-nixd.socket:/nix/var/determinate/determinate-nixd.socket:ro"
              "--env SETUP_NIX_SCRIPT=${setup-nix-script}"

              # Hardware acceleration
              "--device /dev/kvm"
              "--device /dev/dri"
            ];
            valid_volumes = ["**"];
          };
        };
      };
    };
  };
}
