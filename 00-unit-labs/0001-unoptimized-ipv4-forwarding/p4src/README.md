# Lab topology
The topology used is common to all unit labs defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
# Lab title:
**Unoptimized IPv4 forwarding**
# Lab objective:
This lab demonstrates basic IPv4 forwarding.
* The `parser` matches only `ipv4` packets.
* Subsequently the `ingress` control apply one **IPv4 host** table that perform `exact` match against host(`/32`) routes.
* and if theres is no match apply a **IPv4 network** table that performs `lpm` match operation againt network(`/cidr`) routes.

# Lab operation
* Run the reference Lab architecture defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
* Compile `unoptimized-ipv4-forwarding.p4` and launch `simple_switch`
```
cd ~/RARE/00-unit-labs/0001-unoptimized-ipv4-forwarding/p4src
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
# entry corresponding to 10.0.1.254 reachability
table_add tbl_ipv4_fib_host act_ipv4_fib_hit 10.0.1.254 => 00:00:0a:00:01:fe 254
# entry corresponding to 10.0.1.254 reachability
table_add tbl_ipv4_fib_host act_ipv4_fib_hit 10.0.1.1  => 00:00:0a:00:01:01 1
```
2 rules are inserted here:
* Control plane directly connected interface
   * P4 Object: TABLE[`tbl_ipv4_fib_host`], ACT_ID[`act_ipv4_fib_hit`], PARAM[`cpe1-eth0@hw_macaddr`,`cpe1-eth0@port_id`].
   * Trigger: IPv4 interface configuration/deletion on FreeRTR.
* ARP entry
   * P4 object: TABLE[`tbl_ipv4_fib_host`], ACT_ID[`act_ipv4_fib_hit`], PARAM[`cpe1-eth0@hw_macaddr`,`cpe1-eth0@port_id`].
   * Trigger: When FreeRTR ARP cache is updated or create/remove this rule.

# Lab verification
* On `cpe1`:
```
sudo ip netns exec cpe1 telnet 127.0.0.1 2323
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
welcome
line ready
cpe1#ping 10.0.1.254 /vrf v1                                                                                                      
pinging 10.0.1.254, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=1/2/6/12
```
* On `core1`:
```
sudo ip netns exec core1 telnet 127.0.0.1 2323
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
welcome
line ready
core1#ping 10.0.1.1 /vrf v1                                                                                                       
pinging 10.0.1.1, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/4/9/21
```
# Key take-away
* In this very first Lab, we tested IPv4 forwarding via `[cpe1-core1]` interconnect subnetwork.
* The P4 switch `p4-core1` is `core1` dataplane.
* Thus it was only necessary to program `tbl_ipv4_fib_host` at P4 switch `p4-core1` level.
* Last but not least, this example works as `arp` mapping was statically applied at FreeRTR level on `cpe1` and `core1` with the `ipv4 host-static <ipv4-address> <hw-address>` command.
 * On `cpe1`:
```
sudo ip netns exec cpe1 telnet 127.0.0.1 2323
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
welcome
line ready
cpe1#sh run int eth0                                                                                                              
interface ethernet0
 no description
 macaddr 0000.0a00.0101
 vrf forwarding v1
 ipv4 address 10.0.1.1 255.255.255.0
 ipv4 host-static 10.0.1.254 0000.0a00.01fe
 no shutdown
 no log-link-change
 exit
!
```
 * On `core1`:
```
sudo ip netns exec core1 telnet 127.0.0.1 2323
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
welcome
line ready
core1#sh run int eth0                                                                                                             
interface ethernet0
 no description
 macaddr 0000.0a00.01fe
 vrf forwarding v1
 ipv4 address 10.0.1.254 255.255.255.0
 ipv4 host-static 10.0.1.1 0000.0a00.0101
 no shutdown
 no log-link-change
 exit
!
```
# Follow-ups
* As we were testing only IPv4 interconnect reachability we had only to use `tbl_ipv4_fib_host` table.
  * For indirect reachability (`static routing`) we will use `tbl_ipv4_fib_lpm` in a [subsequent Lab](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0002-static-routing-ipv4-forwarding/p4src).
* This Lab is called: `Unoptimized IPv4 forwarding` simply because the `tbl_ipv4_fib_[host|lpm]` has a `lookup key` that can resolve in the same `nexthop`. (i.e several network can have the same netxhop egress port) Therefore `tbl_ipv4_fib_[host|lpm]` is containing multiple occurrence of the same nexthop information which is a waste of TCAM resource. A rule of thumb is to minimise the number of fields used by the key lookup operation.
  * `Optimized IPv4 forwarding` will be the object of a subsequent lab.
* Considering the previous section, this `arp` mapping must be dynamic especially in production environment.   
    * `L2 learning` will be the object of a subsequent Lab.
