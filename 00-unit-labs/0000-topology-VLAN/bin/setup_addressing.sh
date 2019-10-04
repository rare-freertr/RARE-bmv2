#!/bin/bash

HOSTNAME=$1
ETH0="$HOSTNAME-eth0"
IPADDRESS=$2
if [ $# -gt 2 ]
then
    VLAN=$3
    ETH0VLAN="$HOSTNAME-eth0.$VLAN"
    ip netns exec $HOSTNAME ip link add link $ETH0 name $ETH0VLAN type vlan id $VLAN
    ip netns exec $HOSTNAME ip addr add $IPADDRESS dev $ETH0VLAN
    ip netns exec $HOSTNAME ip link set dev $ETH0VLAN up
else
    ip netns exec $HOSTNAME ip addr add $IPADDRESS dev $ETH0
    ip netns exec $HOSTNAME ip link set dev $ETH0 up
fi

