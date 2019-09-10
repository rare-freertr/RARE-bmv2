#!/bin/bash

FREERTR_HOME=$(pwd)
FREERTR_HOSTNAME=r4
FREERTR_ETH0="veth5"
P4_SWITCH_DP4="veth4"

ip link add $FREERTR_ETH0 type veth peer name $P4_SWITCH_DP4

ip link set dev $P4_SWITCH_DP4 up
ip link set dev $FREERTR_ETH0 up

$FREERTR_HOME/bin/freertr.sh -i "$FREERTR_ETH0/22717/22718" -r "$FREERTR_HOSTNAME" 

