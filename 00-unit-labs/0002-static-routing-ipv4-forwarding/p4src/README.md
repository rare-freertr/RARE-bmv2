# Lab topology
The topology used is common to all unit labs defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
# Lab title
**Static routing - IPv4 forwarding**
# Lab objective
This lab demonstrates basic IPv4 forwarding between disjoint subnetworks. (The previous lab was testing IPv4 forwarding directly  connected interface between `cpe1` and `core1`)
* The same P4 program as [previous lab](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0001-unoptimized-ipv4-forwarding/p4src) is used.
* Connectivity to a disjoint subnetwork (`10.254.254.254/32`) on `core1` is tested from `cpe1`.
* Connectivity to another disjoint subnetwork (`2.2.2.0/24`) on `cpe2` is tested from `cpe1`.

# Lab operation
* Run the reference Lab architecture defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
* Compile `unoptimized-ipv4-forwarding.p4` and launch `simple_switch`
```
cd ~/RARE/00-unit-labs/0002-static-routing-ipv4-forwarding/p4src
make
```

# Control Plane operation
* Connect `p4-core1` via CLI:
```
simple_switch_CLI --thrift-port 9090
Obtaining JSON from switch...
Done
Control utility for runtime P4 table manipulation
RuntimeCmd:
```
* Program same entries as the [previous lab](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0001-unoptimized-ipv4-forwarding/p4src). (Entries in `tbl_ipv4_fib_host` table)
```
# entry corresponding to 10.0.1.254 reachability
table_add tbl_ipv4_fib_host act_ipv4_fib_hit 10.0.1.254 => 00:00:0a:00:01:fe 254
# entry corresponding to 10.0.1.254 reachability
table_add tbl_ipv4_fib_host act_ipv4_fib_hit 10.0.1.1  => 00:00:0a:00:01:01 1
```
* `10.254.254.254/32` reachability test from `cpe1`
   * Configure `10.254.254.254/32` host route on `core1`
```
core1#sh run int lo0                                                                                                              
interface loopback0
 no description
 macaddr 0000.0afe.fefe
 vrf forwarding v1
 ipv4 address 10.254.254.254 255.255.255.255
 no shutdown
 no log-link-change
 exit
!
```
   * Add a static route in vrf `v1` on `cpe1` toward `10.254.254.254/32` configured on `core1`
```
# pay attention that the IP nexthop is core1@core1-eth0 => 10.0.1.254
cpe1#conf
ipv4 route v1 10.254.254.254 255.255.255.255 10.0.1.254
```
   * Add rule on `p4-core1` for `10.254.254.254` reachability
```
# P4 Object: tbl_ipv4_fib_host
# Table key: `10.254.254.254`
# Action id: act_ipv4_fib_hit
# Action params: {00:00:0a:00:01:fe,254}
# Trigger: when the subnetwork is configured on `core1` on `loopback0` interface   
table_add tbl_ipv4_fib_host act_ipv4_fib_hit 10.254.254.254 => 00:00:0a:00:01:fe 254
```
* `2.2.2.0/24` reachability test from `cpe1`
   * Configure `2.2.2.0/24` host route on `cpe2`
```
cpe2#sh run int lo1                                                                                                               
interface loopback1
 no description
 vrf forwarding v1
 ipv4 address 2.2.2.2 255.255.255.0
 no shutdown
 no log-link-change
 exit
!
```
   * Add a static route in vrf `v1` on `cpe1` toward `2.2.2.0/24` configured on `cpe2`
```
# pay attention that the IP nexthop is core1@core1-eth0 => 10.0.1.254
cpe1#conf
ipv4 route v1 2.2.2.0 255.255.255.0 10.0.1.254
```
   * Add rule on `p4-core1` for `2.2.2.0/24` reachability
```
# P4 Object: tbl_ipv4_fib_lpm
# Action id: act_ipv4_fib_hit
# Table key: 2.2.2.0/24
# Action params: {00:00:0a:00:02:02,2}
# Trigger: when the static route toward 2.2.2.0/24 is configured on `core1`
table_add tbl_ipv4_fib_lpm act_ipv4_fib_hit 2.2.2.0/24 => 00:00:0a:00:02:02 2
```
* Add `static route` toward `2.2.2.0/24` reachability information from `core1` via `cpe2-eth0`
```
# pay attention that the IP nexthop is cpe2@cpe2-eth0 => 10.0.2.2
core1#conf
ipv4 route v1 2.2.2.0 255.255.255.0 10.0.2.2
```

# Lab verification
* `10.254.254.254` configured `core1` reachability test from `cpe1`:
```
sudo ip netns exec cpe1 telnet 127.0.0.1 2323
[sudo] password for floui:
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
welcome
line ready
cpe1#ping 10.254.254.254 /vrf v1                                                                                                  
pinging 10.254.254.254, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=0/1/2/5
cpe1#                                                                                   
```
* `2.2.2.0/24` configured on `cpe2` reachability test from `cpe1`:
```
sudo ip netns exec cpe1 telnet 127.0.0.1 2323
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
welcome
line ready
cpe1#ping 2.2.2.2 /vrf v1                                                                                                         
pinging 2.2.2.2, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=1/1/2/7
cpe1#                                                                                  
```
# Key take-away
* In this 2nd Lab, we tested IPv4 forwarding via non directly connected subnetworks.
* In addition to `tbl_ipv4_fib_host`, `tbl_ipv4_fib_lpm` table is also used in order to match network route.
* Reachability information is provided by `static routing`.
On `core1`, configuring `10.254.254.254/32`@`loopback0` must trigger `entry` creation on `p4-core1` that point to the right hardware nexthop, here `p4-core1-cpu1`. Note that it could have been any of the `core1-cpu<x>` port.
* On `core1`, configuring `stating route` must trigger `entry` creation on `p4-core1` that point to the right hardware nexthop via the dataplane port (here `p4-core1-dp2`).
* Last but not least, regarding the `2.2.2.0/24` reachability test, if you `tcpdump` `core1` interface you should see no packet transition from `cpe1` to `core1`. This is normal as `core1` in this case is just a transit node. All the packets are switched by `p4-core1` P4 Swicth directly to `cpe2`. (which is what we expected)

# Follow-ups
* This lab inherit from the [previous lab](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0001-unoptimized-ipv4-forwarding/p4src) called: `Unoptimized IPv4 forwarding`. Therefore in the current state, this program still needs to be optimized in a subsequent Lab.
  * This `Optimized IPv4 forwarding` will be the object of a subsequent lab.
* L2 is still statically learned, this `arp` mapping must be dynamic especially in production environment.   
    * `L2 learning` will be the object of a subsequent Lab.
