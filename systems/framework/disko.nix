{
  # nixos-generate-config --root /tmp/config --no-filesystems
  # cp /tmp/config/etc/nixos/hardware-configuration.nix systems/framework/hardware-configuration.nix
  # echo "<encryption-key>" > /tmp/secret.key
  # bin/disko-install-nixos framework
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "5G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          encryption = "on";
          keyformat = "passphrase";
          keylocation = "file:///tmp/secret.key";
        };
        mountpoint = "/";
        options = {
          cachefile = "none";
        };
        postCreateHook = ''
          zfs set keylocation="prompt" "zroot";
          zfs list -t snapshot -H -o name | grep -E '^zroot@blank$' || zfs snapshot zroot@blank
        '';
      };
    };
  };
}
