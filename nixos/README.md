# Running `RARE` Labs on nixpkgs/NixOS

## nixpkgs on Debian 10

We start off with a plain Debian 10 system
```
$ cat /etc/debian_version 
10.3
```
[Install](https://nixos.org/download.html) the `nixpkgs` package manager 
```
$ curl -L https://nixos.org/nix/install | sh
```
and execute
```
$ . /home/debian/.nix-profile/etc/profile.d/nix.sh
```
as instructed. This installs the bare minimum required to manage
packages with Nix.

The packages required to run the RARE labs are based on the `nixpkgs`
release 19.03.  After following the instructions above, you probably
have a newer release installed, so let's change this to 19.03.

In Nix, the mechanism to do this is called a _channel_ (think of it
as a repository for a particular release of a traditional Linux
distribution).  A channel has a name and a URL, e.g.

```
$ nix-channel --list
nixpkgs https://nixos.org/channels/nixpkgs-unstable
```
The name of the standard channel is `nixpkgs`.  We replace it with the
channel 19.03 as follows.
```
$ nix-channel --remove nixpkgs
uninstalling 'nixpkgs-20.09pre235417.c64722a7b19'
building '/nix/store/xsk9wjy0dpp7w7d3r3bkzxzaklqdzq6q-user-environment.drv'...
created 0 symlinks in user environment
$ nix-channel --add https://nixos.org/channels/nixpkgs-19.03-darwin nixpkgs
$ nix-channel --update
unpacking channels...
created 1 symlinks in user environment
$
```

The `nixpkgs` distribution contains most dependencies required by the
P4-specific code needed to run the RARE labs.  However, some of those
dependencies need to be modified to use different versions or build
parameters than what comes with the standard `nixpkgs` 19.03.  The
mechanism in Nix that allows one to override these build recipes as
well as add new packages is called
[overlays](https://nixos.org/nixpkgs/manual/#chap-overlays).

To install those overlays, first clone into the RARE repository
```
$ git clone https://github.com/frederic-loui/RARE.git
$ cd RARE/nixos
```
The overlays are installed for your user by executing a `Makefile`
target
```
$ make install-nix-overlays-nixpkgs
```

So far, no packages have been built yet. We have merely installed the
rules that tell Nix *how* to build them.  The build process is started
only when we attempt to actually use them.

In principle, one could add the packages to one's environment by using
the `nix-env` utility, which would build the packages and make them
available through symbolic links in `~/.nix-profile/` (the packages
themselves are located in `/nix/store`).  In particular, the
executables would be exposed (in this case) through the element
`/home/debian/.nix-profile/bin` in `$PATH`

```
$ echo $PATH
/home/debian/.nix-profile/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
```

But Nix also provides a way to use packages without cluttering the
user's environment by using the `nix-shell` utility.  It creates a
subshell with an environment in which all required dependencies are
present until the shell is terminated.  For RARE, this is done by
executing

```
$ nix-shell nixos/RARE-env.nix
```

in the top-level directory of the RARE repository. The file
`RARE-env.nix` contains a piece of Nix code that essentially specifies
which packages must be present in the environment.

When executed for the first time, it will download a lot of standard
packages from `cache.nixos.org` and then proceed to re-build the
packages from `nixpkgs` 19.03 that we have modified and also build the
packages that we have added in our overlay and which are not part of
`nixpkgs` 19.03.

You can now execute the `RARE` labs as usual inside this shell. If you
quit the shell, execute `make nix-env` again to re-create it (this
will complete much faster since all dependencies have already been
built).

## On a native NixOS system

Make sure that the system is running NixOS 19.03 and downgrade if necessary

```
# nixos-version 
20.03post-git (Markhor)
# nix-channel --remove nixos
building '/nix/store/xsk9wjy0dpp7w7d3r3bkzxzaklqdzq6q-user-environment.drv'...
created 0 symlinks in user environment

# nix-channel --add  https://nixos.org/channels/nixos-19.03 nixos

# nix-channel --update
unpacking channels...
created 1 symlinks in user environment
```

For the changes to take effect, the system has to be rebuilt

```
# nixos-rebuild switch
[lots of output]
# nixos-version
19.03.173691.34c7eb7545d (Koi)
```

Make sure you have Git and GNUmake in your user environment
```
$ nix-env -iA nixos.gitAndTools.gitFull nixos.gnumake
```

Checkout the `RARE` repo and execute as root (you may have to install `gnumake` for root as well)

```
$ git clone https://github.com/frederic-loui/RARE.git
```

On NixOS we have the choice to install the `nixpkgs` overlay at the
user level or at the system level.

### Add overlays at the user level

This works in exactly the same way as described before. Execute

```
# make install-nix-overlays-nixpkgs
```

in the `nixos` directory of the repository, then

```
$ nix-shell nixos/RARE-env.nix
```

### Add overlays at the system level

To enable the overlays for the entire system, add

```
  nixpkgs.overlays = import /etc/nixos/overlays/overlays.nix;

  nix.nixPath = options.nix.nixPath.default ++
                  lib.singleton "nixpkgs-overlays=/etc/nixos/overlays-compat/";
```

to `/etc/nixos/configuration.nix` and make sure the function arguments
in `confiuguration.nix` include `options`, e.g.

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
$ nix-shell nixos/RARE-env.nix
```
