#!/bin/bash

FREERTR_HOME=$(pwd)
FREERTR_HOSTNAME=r2
FREERTR_ETH0="veth3"
FREERTR_ETH1="$FREERTR_HOSTNAME-eth1"
P4_SWITCH_DP2="veth2"
R3_INTF="r3-eth0"

ip link add $FREERTR_ETH0 type veth peer name $P4_SWITCH_DP2
ip link add $FREERTR_ETH1 type veth peer name $R3_INTF 

ip link set dev $P4_SWITCH_DP2 up
ip link set dev $FREERTR_ETH0 up
ip link set dev $FREERTR_ETH1 up

$FREERTR_HOME/bin/freertr.sh -i "$FREERTR_ETH0/22707/22708 $FREERTR_ETH1/22713/22714" -r "$FREERTR_HOSTNAME"

