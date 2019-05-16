# Lab topology

![Lab diagram](https://github.com/frederic-loui/RARE/raw/master/resources/0000-topology.png)

# Unit test topology
The topology depicted in the diagram above is the topology used in all unit tests.    
Each unit test is meant to validate a precise features in this setup.  

The role of each components are:

* `cpe1` & `cpe2` are both FreeRTR router control plane that is using linux raw socket dataplane. 
* `core1` is a FreeRTR control plane that is using P4Lang BMV2 `simple_switch` or `simple_switch_grpc` as P4 dataplane. 
* `cpe1` runs in its own linux namespace `cpe1` and is attached via `cpe1-eth0` in to `core1-p4-switch` via `p4-core1-dp1` 
* `cpe2` runs in its own linux namespace `cpe2` and is attached via `cpe2-eth0` in to `core1-p4-switch` via `p4-core1-dp2` 
* `core1-freertr-controller` is connected respectively via `core1-eth0` & `core1-eth1` to `core1-p4-switch` via `p4-core1-cpu1` & `p4-core1-cpu2`
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


