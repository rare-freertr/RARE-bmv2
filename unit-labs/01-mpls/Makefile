
BUILD_DIR = build
PCAP_DIR = pcaps
LOG_DIR = logs

TOPO = topology.json

P4C = p4c
RUN_SCRIPT = p4_controller.py

source := $(wildcard *.p4)
json_outfile := $(source:.p4=.json)
p4info_outfile := $(source:.p4=.txt)

compiled_json := $(BUILD_DIR)/$(json_outfile)
compiled_p4info := $(BUILD_DIR)/$(p4info_outfile)

# Define NO_P4 to start BMv2 without a program
ifndef NO_P4
run_args += -j $(compiled_json)
endif

# Set BMV2_SWITCH_EXE to override the BMv2 target
ifdef BMV2_SWITCH_EXE
run_args += -b $(BMV2_SWITCH_EXE)
endif

all: run

run: mpls.p4
	$(P4C) --std p4-16 --target bmv2 --arch v1model \
	    -o $(BUILD_DIR) --p4runtime-files $(compiled_p4info) mpls.p4

controller: p4_controller.py
	sudo python $(RUN_SCRIPT) \
		--p4info $(compiled_p4info) \
		--bmv2-json $(compiled_json)

stop:
	sudo mn -c

clean: stop
	rm -f *.pcap
	rm -rf $(BUILD_DIR) $(PCAP_DIR) $(LOG_DIR)

