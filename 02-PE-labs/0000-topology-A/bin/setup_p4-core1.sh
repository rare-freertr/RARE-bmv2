#!/usr/bin/env bash

# Example of simple_switch with ipv4.json
# sudo simple_switch --log-console -i 1@p4-core1-dp1 -i 2@p4-core1-dp2 -i 255@p4-core1-cpu1 -i 254@p4-core1-cpu2 --thrift-port 9090 --nanolog ipc:///tmp/bm-0-log.ipc --device-id 0 ipv4.json
