.DEFAULT_GOAL = none

none:

install-nix-overlays:
	cp -r nixos-setup/overlays* /etc/nixos

nix-env: nix-env.nix
	nix-shell $< || true
