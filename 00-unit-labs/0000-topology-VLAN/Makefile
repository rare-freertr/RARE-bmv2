BASE_DIR=$(PWD)
BIN_DIR=$(BASE_DIR)/bin
all:
	sudo $(BIN_DIR)/setup_host.sh "host1" "p4-core1-dp1"
	sudo $(BIN_DIR)/setup_host.sh "host2" "p4-core1-dp2"
	sudo $(BIN_DIR)/setup_host.sh "host3" "p4-core1-dp3"
	sudo $(BIN_DIR)/setup_host.sh "host4" "p4-core1-dp4"

	sudo $(BIN_DIR)/setup_addressing.sh "host1" "192.168.69.1/24"
	sudo $(BIN_DIR)/setup_addressing.sh "host2" "192.168.69.2/24" "102"
	sudo $(BIN_DIR)/setup_addressing.sh "host3" "192.168.69.3/24" "103"
	sudo $(BIN_DIR)/setup_addressing.sh "host3" "192.168.69.4/24" "104"
clean:
	sudo $(BIN_DIR)/teardown_host.sh "host1"
	sudo $(BIN_DIR)/teardown_host.sh "host2"
	sudo $(BIN_DIR)/teardown_host.sh "host3"
	sudo $(BIN_DIR)/teardown_host.sh "host4"
