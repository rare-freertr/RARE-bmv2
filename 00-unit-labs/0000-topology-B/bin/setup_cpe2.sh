#!/bin/bash

FREERTR_HOME=$(pwd)
FREERTR_HOSTNAME=cpe2
FREERTR_ETH0="$FREERTR_HOSTNAME-eth0"
FREERTR_ETH1="$FREERTR_HOSTNAME-eth1"

ip netns add $FREERTR_HOSTNAME
ip link add $FREERTR_ETH0 type veth peer name p4-core1-dp2
ip link set $FREERTR_ETH0 netns $FREERTR_HOSTNAME

ip link add $FREERTR_ETH1 type veth peer name cpe3-eth0
ip link set $FREERTR_ETH1 netns $FREERTR_HOSTNAME

ip link set dev p4-core1-dp2 up
ip netns exec $FREERTR_HOSTNAME ip link set dev $FREERTR_ETH0 up
ip netns exec $FREERTR_HOSTNAME ip link set dev $FREERTR_ETH1 up
ip netns exec $FREERTR_HOSTNAME ip link set dev lo up       

ip netns exec $FREERTR_HOSTNAME $FREERTR_HOME/bin/freertr.sh -i "$FREERTR_ETH0/22707/22708 $FREERTR_ETH1/22713/22714" -r "$FREERTR_HOSTNAME"
