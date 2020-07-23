#!/usr/bin/env bash

ip netns exec core1 ip link set core1-eth0 down
ip netns exec core1 ip link set core1-eth1 down
ip netns exec core1 ip link set core1-eth0 netns 1
ip netns exec core1 ip link set core1-eth1 netns 1
ip link delete dev core1-eth0
ip link delete dev core1-eth1

ip netns delete core1

