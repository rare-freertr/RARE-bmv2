#!/bin/bash

HOSTNAME=$1
ETH0="$HOSTNAME-eth0"

ip netns add $HOSTNAME
ip link add $ETH0 type veth peer name p4-core1-dp1
ip link set $ETH0 netns $HOSTNAME

ip link set dev p4-core1-dp1 up
ip netns exec $HOSTNAME ip link set dev $ETH0 up
ip netns exec $HOSTNAME ip link set dev lo up       


