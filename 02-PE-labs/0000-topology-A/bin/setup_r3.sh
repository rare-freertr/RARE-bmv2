#!/bin/bash

FREERTR_HOME=$(pwd)
FREERTR_HOSTNAME=r3
FREERTR_ETH0="$FREERTR_HOSTNAME-eth0"
R2_INTF="r2-eth1"

ip link add $FREERTR_ETH0 type veth peer name $R2_INTF 
ip link set dev $FREERTR_ETH0 up

$FREERTR_HOME/bin/freertr.sh -i "$FREERTR_ETH0/22715/22716" -r "$FREERTR_HOSTNAME" 

