# Running `RARE` Labs on a pure NixOS System

The following requires a generic NixOS 19.03 installation.

Make sure you have Git and GNUmake in your user environment
```
$ nix-env -iA nixos.gitAndTools.gitFull
$ nix-env -iA nixos.gnumake
```

Checkout the `RARE` repo and execute as root (you may have to install `gnumake` for root as well)
```
# make install-nix-overlays
```
Add
```
  nixpkgs.overlays = import /etc/nixos/overlays/overlays.nix;

  nix.nixPath = options.nix.nixPath.default ++
                  singleton "nixpkgs-overlays=/etc/nixos/overlays-compat/";
```
to `/etc/nixos/configuration.nix` and make sure the function argumenst in `confiuguration.nix` include `options`, e.g.
```
$ head -1 /etc/nixos/configuration.nix
{ config, lib, pkgs, options, ... }:

```
Rebuild the system
```
# nixos-rebuild switch
```
Log out and back in to update `$NIX_PATH`. It should looke something like this (note the `nixpkgs-overlays=`)
```
$ echo $NIX_PATH
nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels:nixpkgs-overlays=/etc/nixos/overlays-compat/
```
Enter the `RARE` top-level directory and execute
```
[user@host:~/RARE]$ make nix-env
[ lots of build output ]
[nix-shell:~/RARE]$
```
This will build all packages from source and create a new shell, where
all required dependencies are present (the shell prompt will change to
`nix-shell` to indicate that you have entered a subshell).  You can
now execute the `RARE` labs as usual inside this shell. If you quit
the shell, execute `make nix-env` again to re-create it (this will
complete much faster since all dependencies have already been built).
