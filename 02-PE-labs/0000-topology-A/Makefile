BASE_DIR=$(PWD)
BIN_DIR=$(BASE_DIR)/bin

all: 
	echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
	sudo $(BIN_DIR)/setup_r1.sh
	sudo $(BIN_DIR)/setup_r2.sh
	sudo $(BIN_DIR)/setup_core1.sh
	sudo $(BIN_DIR)/setup_r3.sh
	sudo $(BIN_DIR)/setup_r4.sh

clean: 
	-sudo pkill -9 pcapInt.bin
	-sudo pkill -9 java
	-sudo $(BIN_DIR)/teardown_r1.sh
	-sudo $(BIN_DIR)/teardown_r2.sh
	-sudo $(BIN_DIR)/teardown_core1.sh
	-sudo $(BIN_DIR)/teardown_r3.sh
	-sudo $(BIN_DIR)/teardown_r4.sh
	#-sudo $(BIN_DIR)/teardown_p4-core1.sh

