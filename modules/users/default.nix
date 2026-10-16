{
  config,
  lib,
  ...
}: let
  cfg = config.meenzen.user;
in {
  options.meenzen.user = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "meenzens";
      description = "Name of the primary user account";
    };
    fullName = lib.mkOption {
      type = lib.types.str;
      default = "Samuel Meenzen";
      description = "Full name of the primary user";
    };
    email = lib.mkOption {
      type = lib.types.str;
      default = "samuel@meenzen.net";
      description = "Email address of the primary user, also used for ACME registration";
    };
    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMa9vjZasAelcVAdtLa+vI0dYvx4hba2z6z+J+u39irB meenzens@framework"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDOHTWbt687mGfFsdxrgSyCtyrb547mw5+SL3FdAT5KeAAAABHNzaDo= YubiKey C"
      ];
      description = "SSH public keys allowed to log in as the primary user and as root";
    };
  };

  config.users.users.${cfg.username} = {
    isNormalUser = true;
    initialPassword = "password";
    openssh.authorizedKeys.keys = cfg.authorizedKeys;
    description = cfg.fullName;
    extraGroups = ["networkmanager" "wheel" "input"];
  };
}
