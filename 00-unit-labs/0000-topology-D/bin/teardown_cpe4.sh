#!/bin/bash

ip netns exec cpe1 ip link set cpe4-eth0 down
ip netns exec cpe1 ip link set cpe4-eth0 netns 1
ip link del dev cpe4-eth0

ip netns delete cpe4

