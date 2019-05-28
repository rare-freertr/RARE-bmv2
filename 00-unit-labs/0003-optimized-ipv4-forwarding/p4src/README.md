# Lab topology
The topology used is common to all unit labs defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
# Lab title:
**Optimized IPv4 forwarding**
# Lab objective
This lab is an optimized version of basic IPv4 forwarding P4 program described in a [previous lab](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0002-static-routing-ipv4-forwarding/p4src). the same reachability tests are kept. (same configuration on `cpe1`, `core1` and `cpe2` FreeRTR for `10.0.1.254`, `10.254.254.254/32` behind `core1` and `2.2.2.0/24` behind `cpe2`).
* **Problem statement:** assume that `core1` is learning from `cpe1` the full routing table. (~ 8M of IPv4 prefixes as of May 2019: https://www.cidr-report.org/as2.0/)
* `core1` would have `cpe1-eth0` with `IP:10.0.1.1` with `hw-address:0000.0a00.0101` at `port:1` via `p4-core1-dp1` as BGP nexthop.
* `tbl_ipv4_fib_lpm` table would then have ~ 8M entries in the form: (using `simple_switch_CLI`)
   * table_add `tbl_ipv4_fib_lpm` `act_ipv4_fib_hit` `<network-id-#1>` `10.0.1.1` => `00:00:0a:00:01:01 1`  
   * table_add `tbl_ipv4_fib_lpm` `act_ipv4_fib_hit` `<network-id-#2>` `10.0.1.1` => `00:00:0a:00:01:01 1`  
   * ...
   * table_add `tbl_ipv4_fib_lpm` `act_ipv4_fib_hit` `<network-id-#8M>` `10.0.1.1` => `00:00:0a:00:01:01 1`  
* Notice that table `tbl_ipv4_fib_lpm` contains redundant information that is wasting memory resources:
   * [`10.0.1.1` => `00:00:0a:00:01:01 1`] x 8M entries
* Solution: use an additional level of indirection by instantiating a 2nd table: `tbl_nexthop` table

# Lab operation
* Run the reference Lab architecture defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
* Compile `optimized-ipv4-forwarding.p4` and launch `simple_switch`
```
cd ~/RARE/00-unit-labs/0003-optimized-ipv4-forwarding/p4src
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
* Program the entries in `tbl_ipv4_fib_host` table
```
# Entry corresponding to 10.0.1.1 reachability
# P4 Object: tbl_ipv4_fib_host
# Table key: 10.0.1.1
# Action id: act_ipv4_fib_hit
# Action params: {1}
# Trigger: when core1 FreeRTR arp cache is updated afer L2 learning
table_add tbl_ipv4_fib_host act_ipv4_set_nexthop 10.0.1.1 => 1
#
# Entry corresponding to 10.0.1.254 reachability
# P4 Object: tbl_ipv4_fib_host
# Table key: 10.0.1.254
# Action id: act_ipv4_fib_hit
# Action params: {254}
# Trigger: when the subnetwork is configured on core1 on core1-eth0 interface   
table_add tbl_ipv4_fib_host act_ipv4_set_nexthop 10.0.1.254 => 254
#
# Entry corresponding to 10.254.254.254 reachability
# P4 Object: tbl_ipv4_fib_host
# Table key: 10.254.254.254
# Action id: act_ipv4_fib_hit
# Action params: {254}
# Trigger: when the subnetwork is configured on core1 on loopback0 interface   
table_add tbl_ipv4_fib_host act_ipv4_set_nexthop 10.254.254.254 => 254
```
* Program the entries in `tbl_ipv4_fib_lpm` table
```
# entry corresponding to 2.2.2.0/24 reachability
# P4 Object: tbl_ipv4_fib_lpm
# Action id: act_ipv4_fib_hit
# Table key: 2.2.2.0/24
# Action params: {2}
# Trigger: when the static route toward 2.2.2.0/24 is configured on `core1`
table_add tbl_ipv4_fib_lpm act_ipv4_set_nexthop 2.2.2.0/24 => 2
```

* Program the entries in `tbl_nexthop` table
```
# Entry corresponding to nexthop reachability 10.0.1.1 via via 00:00:0a:00:01:01 port 1
# P4 Object: tbl_nexthop
# Table key: 1
# Action id: act_ipv4_fib_hit
# Action params: {00:00:0a:00:01:01,1}
# Trigger: when core1 FreeRTR arp cache is updated afer L2 learning
table_add tbl_nexthop act_ipv4_fib_hit 1 => 00:00:0a:00:01:01 1
#
# Entry corresponding to nexthop reachability 10.0.2.2 via via 00:00:0a:00:02:02 port 2
# P4 Object: tbl_nexthop
# Table key: 2
# Action id: act_ipv4_fib_hit
# Action params: {00:00:0a:00:02:02,2}
# Trigger: when core1 FreeRTR arp cache is updated afer L2 learning
table_add tbl_nexthop act_ipv4_fib_hit 2 => 00:00:0a:00:02:02 2
#
# Entry corresponding to nexthop reachability 10.0.1.254 via via 00:00:0a:00:01:fe port 254
# P4 Object: tbl_nexthop
# Table key: 254
# Action id: act_ipv4_fib_hit
# Action params: {00:00:0a:00:01:fe,254}
# Trigger: when core1 FreeRTR core1-eth0 is configured
table_add tbl_nexthop act_ipv4_fib_hit 254 => 00:00:0a:00:01:fe 254
```
# Lab verification
* On `cpe1`:
```
sudo ip netns exec cpe1 telnet 127.0.0.1 2323
[sudo] password for floui:
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
welcome
line ready
cpe1#ping 10.0.1.254 /vrf v1                                                                                                      
pinging 10.0.1.254, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=1/3/10/19
cpe1#ping 10.254.254.254 /vrf v1                                                                                                  
pinging 10.254.254.254, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=1/2/7/13
cpe1#ping 2.2.2.2 /vrf v1                                                                                                         
pinging 2.2.2.2, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/2/3/12
#cpe1
```
* On `core1`:
```
sudo ip netns exec core1 telnet 127.0.0.1 2323   
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
welcome
line ready
core1#ping 10.0.1.254 /vrf v1                                                                                                     
pinging 10.0.1.254, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=0/0/3/6
core1#                                                                    
```
# Key take-away
* This labs proposed a memory optimization of IPv4 forwarding P4 program.
* This optimization is enabled by the creation of an additional `tbl_nexthop` table.
* This new table structure has to be taken into account by the control plane. (FreeRTR)
* For this example we are using `simple_switch_CLI` and know the structure beforehand.
* But generally, the control plane pilot the dataplane via interface like GRPC P4Runtime and get to know this structure using the `P4Info` file generated at compilation time of the P4 program.
* Last but not least, this example works as `arp` mapping was statically applied at FreeRTR level on `cpe1` and `core1` with the `ipv4 host-static <ipv4-address> <hw-address>` command.

# Follow-ups
* It you pay attention carefully to this example, we introduced a custom `metadata_t` that contains the `nexthop_id` information.
   * `metadata` usage will be the object of a subsequent Lab.
* Considering the previous section, this `arp` mapping must be dynamic especially in production environment.   
   * `L2 learning` will be the object of a subsequent Lab.
