#!/bin/bash

ip link set veth251 down
ip link set core1-grpc down
ip link delete dev veth251 
ip link delete dev core1-grpc

