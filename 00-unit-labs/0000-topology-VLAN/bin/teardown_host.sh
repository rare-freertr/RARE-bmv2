#!/bin/bash

HOSTNAME=$1
ETH0="$HOSTNAME-eth0"

ip netns exec $HOSTNAME ip link set $ETH0 down
ip netns exec $HOSTNAME ip link set $ETH0 netns 1
ip link del dev $ETH0

ip netns delete $HOSTNAME
