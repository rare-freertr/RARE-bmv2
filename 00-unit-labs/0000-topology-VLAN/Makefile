BASE_DIR=$(PWD)
BIN_DIR=$(BASE_DIR)/bin
all: 
	sudo $(BIN_DIR)/setup_host.sh "host1"
	sudo $(BIN_DIR)/setup_host.sh "host2"
	sudo $(BIN_DIR)/setup_host.sh "host3"
	sudo $(BIN_DIR)/setup_host.sh "host4"

clean:
	sudo $(BIN_DIS)/teardown_host.sh "host1"
	sudo $(BIN_DIS)/teardown_host.sh "host2"
	sudo $(BIN_DIS)/teardown_host.sh "host3"
	sudo $(BIN_DIS)/teardown_host.sh "host4"
