BASE_DIR=$(PWD)
BIN_DIR=$(BASE_DIR)/bin

.DEFAULT_GOAL = all

$(BIN_DIR)/rawInt.bin: $(BIN_DIR)/rawInt.bin.in
	. /etc/os-release; \
	if [ $$ID = "nixos" ]; then \
	  cp $@.nixos $@; \
	else \
	  cp $? $@; \
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
