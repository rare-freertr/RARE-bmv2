#!/bin/sh

BUILD_DIR=build

# Step 1: Create *.json and *.p4info
make

# Step 2: Launch run_exercice.py 
#         using topology.json, p4 switch config  (make output file) 
#         and bmv2 target to launch
#       - topology.json
#       - *.json
#       - "simple_switch_grpc"
sudo python ../../utils/run_exercise.py \
    --topo topology.json \
    --switch_json build/mpls.json \
    --behavioral-exe simple_switch_grpc \
    --host_mode 6
