#!/bin/bash

FREERTR_HOME=$(pwd)
FREERTR_HOSTNAME=cpe4
FREERTR_ETH0="$FREERTR_HOSTNAME-eth0"

ip netns add $FREERTR_HOSTNAME
ip link add $FREERTR_ETH0 type veth peer name p4-core1-dp4
ip link set $FREERTR_ETH0 netns $FREERTR_HOSTNAME

ip link set dev p4-core1-dp4 up
ip netns exec $FREERTR_HOSTNAME ip link set dev $FREERTR_ETH0 up
ip netns exec $FREERTR_HOSTNAME ip link set dev lo up       

ip netns exec $FREERTR_HOSTNAME $FREERTR_HOME/bin/freertr.sh -i "$FREERTR_ETH0/22715/22716" -r "$FREERTR_HOSTNAME" 

