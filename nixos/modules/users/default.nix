{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  users.users = {
    meenzens = {
      initialPassword = "password123";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMa9vjZasAelcVAdtLa+vI0dYvx4hba2z6z+J+u39irB meenzens@framework"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDOHTWbt687mGfFsdxrgSyCtyrb547mw5+SL3FdAT5KeAAAABHNzaDo= YubiKey C"
      ];
      description = "Samuel Meenzen";
      extraGroups = ["networkmanager" "wheel" "docker" "vboxusers" "input"];
      shell = pkgs.zsh;
    };
  };
}
