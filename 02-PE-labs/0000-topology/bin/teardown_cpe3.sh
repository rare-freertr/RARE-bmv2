#!/usr/bin/env bash

ip netns exec cpe3 ip link set cpe3-eth0 down
ip netns exec cpe3 ip link set cpe3-eth0 netns 1
ip link delete dev cpe3-eth0

ip netns delete cpe3

