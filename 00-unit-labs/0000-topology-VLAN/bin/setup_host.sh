#!/bin/bash

HOSTNAME=$1
ETH0="$HOSTNAME-eth0"
CORELINK=$2

ip netns add $HOSTNAME
ip link add $ETH0 type veth peer name $CORELINK
ip link set $ETH0 netns $HOSTNAME

ip link set dev $CORELINK up
ip netns exec $HOSTNAME ip link set dev $ETH0 up
ip netns exec $HOSTNAME ip link set dev lo up       


