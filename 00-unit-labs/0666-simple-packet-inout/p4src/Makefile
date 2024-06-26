BUILD_DIR = ../build
RUN_DIR = ../run
LOG_DIR = $(RUN_DIR)/log
LOG_FILE = p4-core1
P4C = p4c
P4_PROGRAM = simple-packet-inout.p4 
BMV2_SWITCH_EXE = simple_switch_grpc

source := $(wildcard *.p4)
json_outfile := $(source:.p4=.json)
p4info_outfile := $(source:.p4=.txt)

compiled_json := $(BUILD_DIR)/$(json_outfile)
compiled_p4info := $(BUILD_DIR)/$(p4info_outfile)

# Set BMV2_SWITCH_EXE to override the BMv2 target
#ifdef BMV2_SWITCH_EXE
#   run_args += -b $(BMV2_SWITCH_EXE)
#endif

all: run

run: build
	sudo $(BMV2_SWITCH_EXE)  --log-file $(LOG_DIR)/$(LOG_FILE) \
			-i 1@p4-core1-dp1 -i 2@p4-core1-dp2 \
			-i 64@p4-core1-cpu1 \
			--thrift-port 9090 --nanolog ipc://$(RUN_DIR)/bm-0-log.ipc --device-id 0 $(compiled_json) \
		        -- --grpc-server-addr 66.66.66.1:50051 > $(LOG_DIR)/$(LOG_FILE).out 2>&1 &

build: dirs 
	$(P4C) --std p4-16 --target bmv2 --arch v1model \
		-I ./ -o $(BUILD_DIR) --p4runtime-files $(compiled_p4info) $(P4_PROGRAM) 

clean: 
	-sudo pkill -9 $(BMV2_SWITCH_EXE)
	-rm -rf $(BUILD_DIR) $(LOG_DIR) $(RUN_DIR)

dirs:
	mkdir -p $(BUILD_DIR) $(LOG_DIR)

