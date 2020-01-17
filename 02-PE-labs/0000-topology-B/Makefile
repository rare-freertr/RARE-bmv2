BASE_DIR=$(PWD)
BIN_DIR=$(BASE_DIR)/bin
SRC_DIR=$(BASE_DIR)/../p4src-modular

all: 
	ip link add veth10a type veth peer name veth10b
	ip link add veth12a type veth peer name veth12b
	ip link add veth1Aa type veth peer name veth1Ab
	ip link add veth20a type veth peer name veth20b
	ip link add veth23a type veth peer name veth23b
	ip link add veth25a type veth peer name veth25b
	ip link add veth30a type veth peer name veth30b
	ip link add veth34a type veth peer name veth34b
	ip link add veth40a type veth peer name veth40b
	ip link add veth48a type veth peer name veth48b
	ip link add veth50a type veth peer name veth50b
	ip link add veth54a type veth peer name veth54b
	ip link add veth59a type veth peer name veth59b
	ip link add veth60a type veth peer name veth60b
	ip link add veth63a type veth peer name veth63b
	ip link add veth67a type veth peer name veth67b
	ip link add veth70a type veth peer name veth70b
	ip link add veth7Ba type veth peer name veth7Bb
	ip link add veth80a type veth peer name veth80b
	ip link add veth8Ca type veth peer name veth8Cb
	$(BIN_DIR)/freertr.sh -i veth10a/11012/11011 -r c1
	$(BIN_DIR)/freertr.sh -i veth20a/11022/11021 -r c2
	$(BIN_DIR)/freertr.sh -i veth30a/11032/11031 -r c3
	$(BIN_DIR)/freertr.sh -i veth40a/11042/11041 -r c4
	$(BIN_DIR)/freertr.sh -i veth50a/11052/11051 -r c5
	$(BIN_DIR)/freertr.sh -i veth60a/11062/11061 -r c6
	$(BIN_DIR)/freertr.sh -i veth70a/11072/11071 -r c7
	$(BIN_DIR)/freertr.sh -i veth80a/11082/11081 -r c8
	$(BIN_DIR)/freertr.sh -i veth59b/11092/11091 -r r9
	$(BIN_DIR)/freertr.sh -i veth1Ab/11102/11101 -r r10
	$(BIN_DIR)/freertr.sh -i veth7Bb/11112/11111 -r r11
	$(BIN_DIR)/freertr.sh -i veth8Cb/11122/11121 -r r12
	ip link set veth10b up
	ip link set veth12a up
	ip link set veth12b up
	ip link set veth1Aa up
	ip link set veth20b up
	ip link set veth23a up
	ip link set veth23b up
	ip link set veth25a up
	ip link set veth25b up
	ip link set veth30b up
	ip link set veth34a up
	ip link set veth34b up
	ip link set veth40b up
	ip link set veth48a up
	ip link set veth48b up
	ip link set veth50b up
	ip link set veth54a up
	ip link set veth54b up
	ip link set veth59a up
	ip link set veth60b up
	ip link set veth63a up
	ip link set veth63b up
	ip link set veth67a up
	ip link set veth67b up
	ip link set veth70b up
	ip link set veth7Ba up
	ip link set veth80b up
	ip link set veth8Ca up
	simple_switch_grpc --thrift-port 9091 -i 64@veth10b -i 2@veth12a -i 10@veth1Aa ../build/router.json -- --grpc-server-addr 127.0.0.1:11010 &
	simple_switch_grpc --thrift-port 9092 -i 64@veth20b -i 1@veth12b -i 3@veth23a -i 5@veth25a ../build/router.json -- --grpc-server-addr 127.0.0.1:11020 &
	simple_switch_grpc --thrift-port 9093 -i 64@veth30b -i 2@veth23b -i 4@veth34a -i 6@veth63b ../build/router.json -- --grpc-server-addr 127.0.0.1:11030 &
	simple_switch_grpc --thrift-port 9094 -i 64@veth40b -i 3@veth34b -i 5@veth54b -i 8@veth48a ../build/router.json -- --grpc-server-addr 127.0.0.1:11040 &
	simple_switch_grpc --thrift-port 9095 -i 64@veth50b -i 2@veth25b -i 4@veth54a -i 9@veth59a ../build/router.json -- --grpc-server-addr 127.0.0.1:11050 &
	simple_switch_grpc --thrift-port 9096 -i 64@veth60b -i 3@veth63a -i 7@veth67a ../build/router.json -- --grpc-server-addr 127.0.0.1:11060 &
	simple_switch_grpc --thrift-port 9097 -i 64@veth70b -i 6@veth67b -i 11@veth7Ba ../build/router.json -- --grpc-server-addr 127.0.0.1:11070 &
	simple_switch_grpc --thrift-port 9098 -i 64@veth80b -i 4@veth48b -i 12@veth8Ca ../build/router.json -- --grpc-server-addr 127.0.0.1:11080 &
	sleep 3
	$(SRC_DIR)/forwarder.py --p4runtime_address 127.0.0.1:11010 --freerouter_address 127.0.0.1 --freerouter_port 9081 &
	$(SRC_DIR)/forwarder.py --p4runtime_address 127.0.0.1:11020 --freerouter_address 127.0.0.1 --freerouter_port 9082 &
	$(SRC_DIR)/forwarder.py --p4runtime_address 127.0.0.1:11030 --freerouter_address 127.0.0.1 --freerouter_port 9083 &
	$(SRC_DIR)/forwarder.py --p4runtime_address 127.0.0.1:11040 --freerouter_address 127.0.0.1 --freerouter_port 9084 &
	$(SRC_DIR)/forwarder.py --p4runtime_address 127.0.0.1:11050 --freerouter_address 127.0.0.1 --freerouter_port 9085 &
	$(SRC_DIR)/forwarder.py --p4runtime_address 127.0.0.1:11060 --freerouter_address 127.0.0.1 --freerouter_port 9086 &
	$(SRC_DIR)/forwarder.py --p4runtime_address 127.0.0.1:11070 --freerouter_address 127.0.0.1 --freerouter_port 9087 &
	$(SRC_DIR)/forwarder.py --p4runtime_address 127.0.0.1:11080 --freerouter_address 127.0.0.1 --freerouter_port 9088 &

clean: 
	-sudo pkill -9 rawInt.bin
	-sudo pkill -9 pcapInt.bin
	-sudo pkill -9 java
	-sudo pkill -9 python2
	-sudo pkill -9 simple_switch_grpc
	-ip link del veth10a
	-ip link del veth12a
	-ip link del veth1Aa
	-ip link del veth20a
	-ip link del veth23a
	-ip link del veth25a
	-ip link del veth30a
	-ip link del veth34a
	-ip link del veth40a
	-ip link del veth48a
	-ip link del veth50a
	-ip link del veth54a
	-ip link del veth59a
	-ip link del veth60a
	-ip link del veth63a
	-ip link del veth67a
	-ip link del veth70a
	-ip link del veth7Ba
	-ip link del veth80a
	-ip link del veth8Ca
