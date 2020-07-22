BASE_DIR=$(PWD)
BIN_DIR=$(BASE_DIR)/bin

.DEFAULT_GOAL = all

$(BIN_DIR)/rawInt.bin: $(BIN_DIR)/rawInt.bin.in
	set -e; \
	. /etc/os-release; \
	cp $? $@; \
	if [ $$ID = "nixos" ]; then \
	  glibc=$$(nix-instantiate --eval -E 'with import <nixpkgs> {}; toString glibc' | sed -e "s/\"//g"); \
	  nix-shell -p patchelf -p glibc --run "patchelf --set-interpreter $$glibc/lib/ld-linux-* $@"; \
	fi

all: $(BIN_DIR)/rawInt.bin
	sudo $(BIN_DIR)/setup_cpe1.sh
	sudo $(BIN_DIR)/setup_cpe2.sh
	sudo $(BIN_DIR)/setup_core1.sh

clean: 
	sudo killall rawInt.bin
	sudo killall java
	sudo $(BIN_DIR)/teardown_cpe1.sh
	sudo $(BIN_DIR)/teardown_cpe2.sh
	sudo $(BIN_DIR)/teardown_core1.sh
	#sudo $(BIN_DIR)/teardown_p4-core1.sh
