#!/bin/bash

ip netns exec cpe2 ip link set cpe2-eth0 down
ip netns exec cpe2 ip link set cpe2-eth0 netns 1
ip link delete dev cpe2-eth0

ip netns delete cpe2

