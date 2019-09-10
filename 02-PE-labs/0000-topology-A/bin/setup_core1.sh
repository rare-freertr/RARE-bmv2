#!/bin/bash

FREERTR_HOME=$(pwd)
FREERTR_HOSTNAME=core1
FREERTR_ETH0="veth251"
FREERTR_GRPC="$FREERTR_HOSTNAME-grpc"
P4_SWITCH_CPU="veth250"
P4_SWITCH_GRPC="p4-$FREERTR_GRPC"

ip link add $FREERTR_ETH0 type veth peer name $P4_SWITCH_CPU 
ip link add $FREERTR_GRPC type veth peer name $P4_SWITCH_GRPC 

ip link set dev $P4_SWITCH_CPU up
ip link set dev $P4_SWITCH_GRPC up
ip link set dev $FREERTR_ETH0 up
ip link set dev $FREERTR_GRPC up

ip addr add 10.10.10.227/24 dev $P4_SWITCH_GRPC 

$FREERTR_HOME/bin/freertr.sh -i "$FREERTR_ETH0/22709/22710" -r "$FREERTR_HOSTNAME"

