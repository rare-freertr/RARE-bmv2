BUILD_DIR = ../build
RUN_DIR = ../run
LOG_DIR = $(RUN_DIR)/log
LOG_FILE = p4-core1
P4C = p4c
P4_PROGRAM = router.p4
BMV2_SWITCH_EXE = simple_switch_grpc

source := $(wildcard *.p4)
json_outfile := $(source:.p4=.json)
p4info_outfile := $(source:.p4=.txt)

compiled_json := $(BUILD_DIR)/$(json_outfile)
compiled_p4info := $(BUILD_DIR)/$(p4info_outfile)

P4_SWITCH_DP1="veth0"
P4_SWITCH_DP2="veth2"
P4_SWITCH_DP4="veth4"
P4_SWITCH_CPU="veth250"
P4_SWITCH_CPU_PORT="64"

all: run

run: build
	sudo $(BMV2_SWITCH_EXE)  --log-file $(LOG_DIR)/$(LOG_FILE) \
			-i 1@$(P4_SWITCH_DP1) -i 2@$(P4_SWITCH_DP2) -i 4@$(P4_SWITCH_DP4) \
			-i $(P4_SWITCH_CPU_PORT)@$(P4_SWITCH_CPU) \
			--thrift-port 9090 --nanolog ipc://$(RUN_DIR)/bm-0-log.ipc --device-id 0 $(compiled_json) \
		        -- --grpc-server-addr 127.0.0.1:50051 > $(LOG_DIR)/$(LOG_FILE).out 2>&1 &
#	./forwarder.py > $(LOG_DIR)/forwarder.log 2>&1 &

build: dirs 
	$(P4C) --std p4-16 --target bmv2 --arch v1model \
		-I ./ -o $(BUILD_DIR) --p4runtime-files $(compiled_p4info) $(P4_PROGRAM) 

clean: 
	-sudo kill -9 `pidof simple_switch_grpc`
	-sudo kill -9 `pidof python2`
	-rm -rf $(BUILD_DIR) $(LOG_DIR) $(RUN_DIR)/bm-0-log.ipc

dirs:
	mkdir -p $(BUILD_DIR) $(LOG_DIR)

