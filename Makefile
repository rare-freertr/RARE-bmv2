.DEFAULT_GOAL = none

none:

nix-env: nix-env.nix
	nix-shell $< || true
