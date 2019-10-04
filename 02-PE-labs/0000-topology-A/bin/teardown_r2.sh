#!/bin/bash

ip link set veth3 down
ip link delete dev veth3 

ip link set r2-eth1 down
ip link delete dev r2-eth1

