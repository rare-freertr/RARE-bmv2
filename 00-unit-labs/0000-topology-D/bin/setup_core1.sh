#!/usr/bin/env bash

FREERTR_HOME=$(pwd)
FREERTR_HOSTNAME=core1
FREERTR_ETH0="$FREERTR_HOSTNAME-eth0"
FREERTR_GRPC="$FREERTR_HOSTNAME-grpc"

ip netns add $FREERTR_HOSTNAME
ip link add $FREERTR_ETH0 type veth peer name p4-core1-cpu1 
ip link add $FREERTR_GRPC type veth peer name p4-core1-grpc 

ip link set $FREERTR_ETH0 netns $FREERTR_HOSTNAME
ip link set $FREERTR_GRPC netns $FREERTR_HOSTNAME

ip link set dev p4-core1-cpu1 up
ip link set dev p4-core1-grpc up
ip netns exec $FREERTR_HOSTNAME ip link set dev $FREERTR_ETH0 up
ip netns exec $FREERTR_HOSTNAME ip link set dev $FREERTR_GRPC up
ip netns exec $FREERTR_HOSTNAME ip link set dev lo up       

ip netns exec $FREERTR_HOSTNAME ip addr add 10.10.10.227/24 dev $FREERTR_GRPC 
ip addr add 10.10.10.1/24 dev p4-core1-grpc


#ip netns exec $FREERTR_HOSTNAME $FREERTR_HOME/bin/freertr.sh -i "$FREERTR_ETH0/22709/22710 $FREERTR_ETH1/22711/22712" -r "$FREERTR_HOSTNAME"
ip netns exec $FREERTR_HOSTNAME $FREERTR_HOME/bin/freertr.sh -i "$FREERTR_ETH0/22709/22710" -r "$FREERTR_HOSTNAME"


