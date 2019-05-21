# Lab topology

![Lab diagram](https://github.com/frederic-loui/RARE/raw/master/resources/0000-topology.png)

# Unit test topology
The topology depicted in the diagram above is the topology used in all unit tests.    
Each unit test is meant to validate a precise features in this setup.  

The role of each components are:

* `cpe1` & `cpe2` are both FreeRTR router control plane that is using linux raw socket dataplane. 
* **core1 block** is a FreeRTR control plane that is using P4Lang BMV2 `simple_switch` or `simple_switch_grpc` as P4 dataplane. 
    * **core1 block** control plane is called `core1`
    * **core1 block** data plane is called p4-core1 dataplane 
* `cpe1` runs in its own linux namespace `cpe1` and is attached via `cpe1-eth0` to `p4-core1` via `p4-core1-dp1` 
* `cpe2` runs in its own linux namespace `cpe2` and is attached via `cpe2-eth0` to `p4-core1` via `p4-core1-dp2` 
* `core1` FreeRTR with p4runtime capability is connected respectively via `core1-eth0` & `core1-eth1` to `p4-core1` via `p4-core1-cpu1` & `p4-core1-cpu2`
* `cpe1-eth0` - `p4-core1-dp1` are veth peers and are dataplane link end points
* `cpe2-eth0` - `p4-core1-dp2` are veth peers and are dataplane link end points
* `core1-eth0` - `p4-core1-cpu1` are veth peers and are control plane link end points
* `core1-eth1` - `p4-core1-cpu2` are veth peers and are control plane link end points

The addressing rules are:    
* `router loopback IP` = 10.`pod_id`.`pod_id`.`pod_id` 
* `router interconnect IP` = 10.0.`pod_id`.`pod_id`
* `hw-mac` = 0000.`<0xIP>` 

Example: 
* `cpe1` `pod_id`=1 : 
* `cpe1 loopback IP` = 10.1.1.1  
* `cpe1 interconnect IP` = 10.0.1.1 
* `cpe1-eth0 hw-mac` = 0000.0A00.0101 

This setup is meant to minimise additional developement at FreeRTR control plane level in oredr to support a P4 dataplane.   

# Run topology
```
git clone https://github.com/frederic-loui/RARE.git
cd RARE/00-unit-labs/0000-topology
make
```
The instructions above run `cpe1`, `cpe2`, in their respective linux namespace     
and run `core1` FreeRTR control plane in the global linux namespace.    
It creates all veth pairs and set `cpe1-eth0`,`cpe2-eth0`, `core1-eth0`, `core1-eth1` into `cpe1`,`cpe2,`core1` namespace.        
`p4-core1-dp1`,`p4-core1-dp2`,`p4-core1-cpu1`,`p4-core1-cpu2` stays in the global namespace.   
It is not creating the P4 switch. `p4-core1` will be run in subsequent labs.   
Let's assume we want to test basic ipv4 forwarding lab and the p4 programe would be `basic-ipv4-forwarding.p4`.     
After compilation the switch config is: `basic-ipv4-forwarding.json`.   
The command to run simple_switch for example will be:    
```
sudo simple_switch --log-file p4-core1 -i 1@p4-core1-dp1 -i 2@p4-core1-dp2 \
			-i 255@p4-core1-cpu1 -i 254@p4-core1-cpu2 \
			--thrift-port 9090 --nanolog ipc:///tmp/bm-0-log.ipc --device-id 0 basic-ipv4-forwarding-ipv4.json 
```

In order to access `simple_switch` P4 switch via CLI:   
```
simple_switch_CLI --thrift-port 9090
```
Please note that we run `simple_switch` and not `simple_switch_grpc` as the objective of the lab is to validate the list of table and related rules.
This can be easily done with `simple_switch_CLI`. `simple_switch_grpc` will be used when we will start writing the rules via FreeRTR controller with GRPC client API.

# Clean topology
```
make clean
```
