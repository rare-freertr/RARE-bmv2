#!/bin/bash

ip netns exec cpe1 ip link set cpe1-eth0 down
ip netns exec cpe1 ip link set cpe1-eth0 netns 1
ip link del dev cpe1-eth0

ip netns delete cpe1

