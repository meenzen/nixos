# NixOS

Personal NixOS configuration.

## Disko

- https://github.com/nix-community/disko/blob/master/docs/quickstart.md
- https://github.com/nix-community/disko/blob/master/docs/disko-install.md

## Hetzner Dedicated Server

This is how to install NixOS on a Hetzner dedicated server using kexec and disko.

1. Boot the Hetzner rescue system (Linux)
2. SSH into the rescue system using the provided password

    ```bash
    ssh root@server-ip
    ```

3. Copy SSH key to rescue system

    ```bash
    ssh-copy-id root@server-ip
    ```

4. `kexec` the NixOS installer image (disconnect within 6 seconds or the terminal session will break)

    ```bash
    curl -L https://github.com/nix-community/nixos-images/releases/latest/download/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz | tar -xzf- -C /root
    /root/kexec/run
    ```

5. Update the nix channel

    ```bash
    nix-channel --update
    ```

6. Create or copy `disko.nix` to the server

    ```bash
    curl -O https://raw.githubusercontent.com/meenzen/nixos/refs/heads/main/systems/neon/disko.nix
    ```

7. Format the disks using disko

    ```bash
    nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount disko.nix
    ```

8. Install NixOS

    ```bash
    nixos-install --flake 'github:meenzen/nixos#neon'
    ```

9. Reboot
10. Wait for the server to come back online, this can take a minute or two
11. Login using SSH

    ```bash
    ssh root@server-ip
    ```

12. Profit!

## Resources / Acknowledgements

- [Unofficial NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/) The best resource for learning NixOS and Flakes.
- [NixOS Config](https://github.com/Nebucatnetzer/nixos) by [@Nebucatnetzer](https://github.com/Nebucatnetzer) inspired me to build my own NixOS configuration.
