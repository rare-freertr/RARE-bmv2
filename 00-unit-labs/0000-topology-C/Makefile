BASE_DIR=$(PWD)
BIN_DIR=$(BASE_DIR)/bin

all: 
	sudo $(BIN_DIR)/setup_cpe1.sh
	sudo $(BIN_DIR)/setup_cpe2.sh
	sudo $(BIN_DIR)/setup_core1.sh

clean: 
	sudo pkill -9 rawInt.bin
	sudo pkill -9 java
	sudo $(BIN_DIR)/teardown_cpe1.sh
	sudo $(BIN_DIR)/teardown_cpe2.sh
	sudo $(BIN_DIR)/teardown_core1.sh
	#sudo $(BIN_DIR)/teardown_p4-core1.sh

