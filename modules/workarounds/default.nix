{...}: {
  imports = [
    ./insecure-packages.nix
    ./libraries.nix
    ./nix-consistency.nix
    ./shebang.nix
    ./zfs.nix
  ];
}
