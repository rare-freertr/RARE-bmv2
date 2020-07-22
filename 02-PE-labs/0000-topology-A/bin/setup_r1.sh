#!/bin/bash

FREERTR_HOME=$(pwd)
FREERTR_HOSTNAME=r1
FREERTR_ETH0="veth1"
P4_SWITCH_DP1="veth0"

ip link add $FREERTR_ETH0 type veth peer name $P4_SWITCH_DP1 

ip link set dev $P4_SWITCH_DP1 up
ip link set dev $FREERTR_ETH0 up

$FREERTR_HOME/bin/freertr.sh -i "$FREERTR_ETH0/22705/22706" -r "$FREERTR_HOSTNAME" 

