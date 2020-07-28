BASE_DIR=$(PWD)

all: 
	-java -jar $(BASE_DIR)/lib/rtr.jar routers $(BASE_DIR)/c1/c1-hw.txt $(BASE_DIR)/c1/c1-sw.txt </dev/null &
	-java -jar $(BASE_DIR)/lib/rtr.jar routers $(BASE_DIR)/c2/c2-hw.txt $(BASE_DIR)/c2/c2-sw.txt </dev/null &
	-java -jar $(BASE_DIR)/lib/rtr.jar routers $(BASE_DIR)/c3/c3-hw.txt $(BASE_DIR)/c3/c3-sw.txt </dev/null &
	-java -jar $(BASE_DIR)/lib/rtr.jar routers $(BASE_DIR)/c4/c4-hw.txt $(BASE_DIR)/c4/c4-sw.txt </dev/null &
	-java -jar $(BASE_DIR)/lib/rtr.jar routers $(BASE_DIR)/c5/c5-hw.txt $(BASE_DIR)/c5/c5-sw.txt </dev/null &
	-java -jar $(BASE_DIR)/lib/rtr.jar routers $(BASE_DIR)/c6/c6-hw.txt $(BASE_DIR)/c6/c6-sw.txt </dev/null &
	-java -jar $(BASE_DIR)/lib/rtr.jar routers $(BASE_DIR)/c7/c7-hw.txt $(BASE_DIR)/c7/c7-sw.txt </dev/null &
	-java -jar $(BASE_DIR)/lib/rtr.jar routers $(BASE_DIR)/c8/c8-hw.txt $(BASE_DIR)/c8/c8-sw.txt </dev/null &
	-java -jar $(BASE_DIR)/lib/rtr.jar routers $(BASE_DIR)/rr1/rr1-hw.txt $(BASE_DIR)/rr1/rr1-sw.txt </dev/null &
	-java -jar $(BASE_DIR)/lib/rtr.jar routers $(BASE_DIR)/rr2/rr2-hw.txt $(BASE_DIR)/rr2/rr2-sw.txt </dev/null &

clean: 
	-pkill -9 java

