# Lab topology
The topology used is common to all unit labs defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
# Lab title
**Unoptimized IPv6 forwarding**
# Lab objective
This lab demonstrates basic IPv6 forwarding.
* The `parser` matches only `ipv6` packets.
* Subsequently the `ingress` control applies one **IPv6 host** table that perform `exact` match against host(`/128`) routes. This table contains
addresses that belong to the router itself (_local_ addresses) and addresses in directly attached networks for which address resolution has been
performed by the control-plane.
* and if theres is no match apply a **IPv6 network** table that performs `lpm` match operation againt network(`/cidr`) routes.

# Lab operation
* Run the reference Lab architecture defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
* Compile `unoptimized-ipv6-forwarding.p4` and launch `simple_switch`
```
cd ~/RARE/00-unit-labs/0008-unoptimized-ipv6-forwarding/p4src
make
```

# Control Plane operation
* P4 tables
   * `tbl_ipv6_fib_host`
      * Key: `<ipv6 address>`
      * Action id: `act_ipv6_fib_local`
        * Action params: {CPU port}
        * Trigger: when the router adds an address that belongs to itself (either a route marked `LOCAL` or a route marked `CONNECTED` with a prefix length of 128)
      * Action id: `act_ipv6_fib_forward`
        * Action params: {source MAC address, destination MAC address, egress port}
        * Trigger: when address resolution for a directly connected neighbor complets
   * `tbl_ipv6_fib_lpm`
      * Key: `<ipv6 prefix>`
      * Action id: `act_ipv6_fib_forward`
        * Action params: {source MAC address, destination MAC address, egress port}
        * Trigger: when address resolution for the next-hop complets
      * Action id: `act_ipv6_fib_glean`
        * Action params: {TBD}
        * Trigger: when a `CONNECTED` prefix is configured
        
* connect to `core1` and display the IPv6 routing table for VRF `v1`
```
$ sudo ip netns exec core1 telnet 127.0.0.1 2323
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
welcome
line ready
core1#show ipv6 route v1                                                                                                          
typ  prefix              metric  iface      hop            time
S    fd00::1/128         1/0     ethernet0  fd00:0:0:1::1  01:11:28
S    fd00::2/128         1/0     ethernet1  fd00:0:0:2::2  01:11:28
C    fd00::fe/128        0/0     loopback0  null           01:11:28
C    fd00:0:0:1::/64     0/0     ethernet0  null           01:11:28
LOC  fd00:0:0:1::fe/128  0/1     ethernet0  null           01:11:28
C    fd00:0:0:2::/64     0/0     ethernet1  null           01:11:28
LOC  fd00:0:0:2::fe/128  0/1     ethernet1  null           01:11:28
S    fd00:0:1:1::/64     1/0     ethernet0  fd00:0:0:1::1  01:11:28
S    fd00:0:2:2::/64     1/0     ethernet1  fd00:0:0:2::2  01:11:28
C    fd00:0:6:6::/64     0/0     loopback1  null           01:11:28
LOC  fd00:0:6:6::6/128   0/1     loopback1  null           01:11:28

core1# 
```
* Check the programming of the p4 tables based on the routing table and (fictitious) ARP requests for directly connected systems
```
$ cat tables.in 
# S    fd00::1/128         1/0     ethernet0  fd00:0:0:1::1  01:11:28
table_add ctl_ingress.l3.tbl_ipv6_fib_lpm ctl_ingress.l3.act_ipv6_fib_forward fd00::1/128 => 00:00:0a:00:01:fe 00:00:0a:00:01:01 1
# S    fd00::2/128         1/0     ethernet1  fd00:0:0:2::2  01:11:28
table_add ctl_ingress.l3.tbl_ipv6_fib_lpm ctl_ingress.l3.act_ipv6_fib_forward fd00::2/128 => 00:00:0a:00:02:fe 00:00:0a:00:02:02 2
# C    fd00::fe/128        0/0     loopback0  null           01:11:28
table_add ctl_ingress.l3.tbl_ipv6_fib_host ctl_ingress.l3.act_ipv6_fib_local fd00::fe => 255
# C    fd00:0:0:1::/64     0/0     ethernet0  null           01:11:28
table_add ctl_ingress.l3.tbl_ipv6_fib_lpm ctl_ingress.l3.act_ipv6_fib_glean fd00:0:0:1::/64
# LOC  fd00:0:0:1::fe/128  0/1     ethernet0  null           01:11:28
table_add ctl_ingress.l3.tbl_ipv6_fib_host ctl_ingress.l3.act_ipv6_fib_local fd00:0:0:1::fe => 255
# C    fd00:0:0:2::/64     0/0     ethernet1  null           01:11:28
table_add ctl_ingress.l3.tbl_ipv6_fib_lpm ctl_ingress.l3.act_ipv6_fib_glean fd00:0:0:2::/64 =>
# LOC  fd00:0:0:2::fe/128  0/1     ethernet1  null           01:11:28
table_add ctl_ingress.l3.tbl_ipv6_fib_host ctl_ingress.l3.act_ipv6_fib_local fd00:0:0:2::fe => 254
# S    fd00:0:1:1::/64     1/0     ethernet0  fd00:0:0:1::1  01:11:28
table_add ctl_ingress.l3.tbl_ipv6_fib_lpm ctl_ingress.l3.act_ipv6_fib_forward fd00:0:1:1::/64 => 00:00:0a:00:01:fe 00:00:0a:00:01:01 1
# S    fd00:0:2:2::/64     1/0     ethernet1  fd00:0:0:2::2  01:11:28
table_add ctl_ingress.l3.tbl_ipv6_fib_lpm ctl_ingress.l3.act_ipv6_fib_forward fd00:0:2:2::/64 => 00:00:0a:00:02:fe 00:00:0a:00:02:02 2
# C    fd00:0:6:6::/64     0/0     loopback1  null           01:11:28
table_add ctl_ingress.l3.tbl_ipv6_fib_lpm ctl_ingress.l3.act_ipv6_fib_glean fd00:0:6:6::/64  =>
# LOC  fd00:0:6:6::6/128   0/1     loopback1  null           01:11:28
table_add ctl_ingress.l3.tbl_ipv6_fib_host ctl_ingress.l3.act_ipv6_fib_local fd00:0:6:6::6 => 255
# Neighbor entry for fd00:0:0:1::1
table_add ctl_ingress.l3.tbl_ipv6_fib_host ctl_ingress.l3.act_ipv6_fib_forward fd00:0:0:1::1 => 00:00:0a:00:01:fe 00:00:0a:00:01:01 1
# Neighbor entry for fd00:0:0:2::2
table_add ctl_ingress.l3.tbl_ipv6_fib_host ctl_ingress.l3.act_ipv6_fib_forward fd00:0:0:2::2 => 00:00:0a:00:02:fe 00:00:0a:00:02:02 2
```
* Program the tables
```
$ make tables
```

# Lab verification
* On `cpe1`:
```
$ sudo ip netns exec cpe1 telnet 127.0.0.1 2323
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
welcome
line ready
cpe1#ping fd00::2 /vrf v1                                                                                                         
pinging fd00::2, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/2/3/16
cpe1#ping fd00::fe /vrf v1                                                                                                        
pinging fd00::fe, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/2/3/15
cpe1#ping fd00:0:0:1::fe /vrf v1                                                                                                  
pinging fd00:0:0:1::fe, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/2/3/13
cpe1#ping fd00:0:0:2::fe /vrf v1                                                                                                  
pinging fd00:0:0:2::fe, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=1/2/3/10
cpe1#ping fd00:0:2:2::2 /vrf v1                                                                                                   
pinging fd00:0:2:2::2, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/3/4/16
cpe1#ping fd00:0:0:2::2 /vrf v1                                                                                                   
pinging fd00:0:0:2::2, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/2/3/15
cpe1#ping fd00:0:6:6::6 /vrf v1                                                                                                   
pinging fd00:0:6:6::6, src=null, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
!!!!!
result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/2/3/14
```
# Key take-away
* This program handles all types of forwarding, i.e. local addresses, directly connected networks and routed networks
* The tables have been designed such that the router's FIB entries can be programmed in a natural manner
* All static routes and IPv6 neighbors are part of the base topology
# Follow-ups
* A subsequent lab will introduce indirection for the next-hop of routed networks to reduce the size of tables and make to make updates to a particular next-hop more efficient
