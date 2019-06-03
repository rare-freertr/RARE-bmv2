# Lab topology
The topology used is common to all unit labs defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
# Lab title:
**ISIS operation**
# Lab objective
This lab objective is to identify the P4 code at the dataplane level (parser, table entries etc.) necessary to enable ISIS operation with FreeRTR control plane.

This lab is based on the previous optimized version of basic IPv4 forwarding P4 program described in a [previous lab](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0003-optimized-ipv4-forwarding/p4src) with additional code.
* Reachability tests are from `cpe1`, `core1` and `cpe2`.
* Each routers has their `loopback0` that are advertised within ISIS as passive networks.
* `cpe1` ping `10.2.2.2` from `10.2.2.2/32` advertized by `cpe2`
* `cpe1` ping `2.2.2.2` from `2.2.2.0/24` advertized by `cpe2`
* `cpe2` ping `10.1.1.1` from `10.1.1.1/32` advertized by `cpe1`
* `cpe2` ping `1.1.1.1` from `1.1.1.0/24` advertized by `cpe1`
* Note that in this lab we are starting to re-use [`switch.p4`](https://github.com/p4lang/switch) piece of code. The approach is to step by step learn also how `switch.p4` is structuring all the features a modern switch can include via P4 dataplane.

# Lab operation
* Run the reference Lab architecture defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
* Compile `isis-operation.p4` and launch `simple_switch`
```
cd ~/RARE/00-unit-labs/0004-isis-operation/p4src
make
```

# Control Plane operation
* Enable ISIS on routers
  * `cpe1`

        cpe1#sh run router isis                                                                                                           
        router isis4 1
         vrf v1
         net-id 49.0001.0000.0a01.0101.00
         traffeng-id ::
         is-type both
         exit

        cpe1#
        cpe1#sh run int lo0                                                                                                               
        interface loopback0
         no description
         macaddr 0000.0a01.0101
         vrf forwarding v1
         ipv4 address 10.1.1.1 255.255.255.255
         router isis4 1 enable
         router isis4 1 passive
         router isis4 1 circuit both
         no shutdown
         no log-link-change
         exit
        !

        cpe1#sh run int eth0                                                                                                              
        interface ethernet0
         no description
         macaddr 0000.0a00.0101
         vrf forwarding v1
         ipv4 address 10.0.1.1 255.255.255.0
         ipv4 host-static 10.0.1.254 0000.0a00.01fe
         router isis4 1 enable
         router isis4 1 circuit both
         no shutdown
         no log-link-change
         exit
        !           
  * `cpe2`
        cpe2#sh run router isis                                                                                                           
        router isis4 1
         vrf v1
         net-id 49.0001.0000.0a02.0202.00
         traffeng-id ::
         is-type both
         exit

        cpe2#   
        cpe2#sh run int lo0                                                                                                               
        interface loopback0
         no description
         macaddr 0000.0a02.0202
         vrf forwarding v1
         ipv4 address 10.2.2.2 255.255.255.255
         router isis4 1 enable
         router isis4 1 passive
         router isis4 1 circuit both
         no shutdown
         no log-link-change
         exit
        !

        cpe2#sh run int eth0                                                                                                              
        interface ethernet0
         no description
         macaddr 0000.0a00.0202
         ipv4 address 10.0.2.2 255.255.255.0
         ipv4 host-static 10.0.2.254 0000.0a00.02fe
         router isis4 1 enable
         router isis4 1 circuit both
         no log-link-change
         exit
        !

        cpe2#                            
  * `core1`
        core1#sh run router isis                                                                                                          
        router isis4 1
         vrf v1
         net-id 49.0001.0000.0afe.fefe.00
         traffeng-id ::
         is-type both
         exit

        core1#
        core1#sh run int lo0                                                                                                              
        interface loopback0
         no description
         macaddr 0000.0afe.fefe
         vrf forwarding v1
         ipv4 address 10.254.254.254 255.255.255.255
         router isis4 1 enable
         router isis4 1 passive
         router isis4 1 circuit both
         no shutdown
         no log-link-change
         exit
        !

        core1#sh run int eth0                                                                                                             
        interface ethernet0
         no description
         macaddr 0000.0a00.01fe
         vrf forwarding v1
         ipv4 address 10.0.1.254 255.255.255.0
         ipv4 host-static 10.0.1.1 0000.0a00.0101
         router isis4 1 enable
         router isis4 1 circuit both
         no shutdown
         no log-link-change
         exit
        !

        core1#sh run int eth1                                                                                                             
        interface ethernet1
         no description
         macaddr 0000.0a00.02fe
         vrf forwarding v1
         ipv4 address 10.0.2.254 255.255.255.0
         ipv4 host-static 10.0.2.2 0000.0a00.0202
         router isis4 1 enable
         router isis4 1 circuit both
         no shutdown
         no log-link-change
         exit
        !

        core1#                         


* Connect `p4-core1` via CLI:
```
simple_switch_CLI --thrift-port 9090
Obtaining JSON from switch...
Done
Control utility for runtime P4 table manipulation
RuntimeCmd:
```
* Program the entries in `tbl_nexthop` table
      # Entry corresponding to nexthop reachability via port p4-core1-dp1
      # P4 Object: tbl_nexthop
      # Table key: 1
      # Action id: act_cpl_opr_fib_hit
      # Action params: {1}
      # Trigger: when core1 FreeRTR is booting up
      table_add tbl_nexthop act_cpl_opr_fib_hit 1 => 1

      # Entry corresponding to nexthop reachability via port p4-core1-dp2
      # P4 Object: tbl_nexthop
      # Table key: 2
      # Action id: act_cpl_opr_fib_hit
      # Action params: {2}
      # Trigger: when core1 FreeRTR is booting up
      table_add tbl_nexthop act_cpl_opr_fib_hit 2 => 2

      # Entry corresponding to nexthop reachability via port p4-core1-cpu1
      # P4 Object: tbl_nexthop
      # Table key: 255
      # Action id: act_cpl_opr_fib_hit
      # Action params: {255}
      # Trigger: when core1 FreeRTR is booting up
      table_add tbl_nexthop act_cpl_opr_fib_hit 255 => 255

      # Entry corresponding to nexthop reachability via port p4-core1-cpu2
      # P4 Object: tbl_nexthop
      # Table key: 254
      # Action id: act_cpl_opr_fib_hit
      # Action params: {254}
      # Trigger: when core1 FreeRTR is booting up
      table_add tbl_nexthop act_cpl_opr_fib_hit 254 => 254


* Program the mac entries in `tbl_rmac_fib` table used in `isis` operation
      # Entry corresponding to router control plane hw-mac address
      # P4 Object: tbl_rmac_fib
      # Table key: 09:00:2b:00:00:05
      # Action id: act_rmac_set_nexthop
      # Action params: {}
      # Trigger: when core1 FreeRTR is enabling 1st isis adjacency
      table_add tbl_rmac_fib act_rmac_set_nexthop 09:00:2b:00:00:05 =>

      # Entry corresponding to router control plane hw-mac address
      # P4 Object: tbl_rmac_fib
      # Table key: 01:80:c2:00:00:15
      # Action id: act_rmac_set_nexthop
      # Action params: {}
      # Trigger: when core1 FreeRTR is enabling 1st isis adjacency
      table_add tbl_rmac_fib act_rmac_set_nexthop 01:80:c2:00:00:15 =>

      # Entry corresponding to router control plane hw-mac address
      # P4 Object: tbl_rmac_fib
      # Table key: 01:80:c2:00:00:14
      # Action id: act_rmac_set_nexthop
      # Action params: {}
      # Trigger: when core1 FreeRTR is enabling 1st isis adjacency
      table_add tbl_rmac_fib act_rmac_set_nexthop 01:80:c2:00:00:14 =>

At this point isis operation is enabled:
* `cpe1`
      cpe1#sh ipv4 isis 1 nei                                                                                                           
      interface  mac address     level  routerid        ip address  uptime
      ethernet0  0000.0000.0000  1      0000.0afe.fefe  10.0.1.254  00:08:19
      ethernet0  0000.0000.0000  2      0000.0afe.fefe  10.0.1.254  00:08:19

      cpe1#                      

* `cpe2`
      cpe2#sh ipv4 isis 1 nei                                                                                                           
      interface  mac address     level  routerid        ip address  uptime
      ethernet0  0000.0000.0000  1      0000.0afe.fefe  10.0.2.254  00:09:11
      ethernet0  0000.0000.0000  2      0000.0afe.fefe  10.0.2.254  00:09:11

* `core1`
      core1#sh ipv4 isis 1 nei                                                                                                          
      interface  mac address     level  routerid        ip address  uptime
      ethernet0  0000.0000.0000  1      0000.0a01.0101  10.0.1.1    00:09:36
      ethernet0  0000.0000.0000  2      0000.0a01.0101  10.0.1.1    00:09:36
      ethernet1  0000.0000.0000  1      0000.0a02.0202  10.0.2.2    00:09:36
      ethernet1  0000.0000.0000  2      0000.0a02.0202  10.0.2.2    00:09:36

But forwarding does not occur even if `core1` control plane `isis` converged.
```
cpe1#ping 10.2.2.2 /vrf v1 /interface lo0                                                                                         
pinging 10.2.2.2, src=10.1.1.1, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
.....
result=0%, recv/sent/lost=0/5/5, rtt min/avg/max/total=10000/0/0/5009
cpe1#                                                                       
```

No worry... This is an expected behaviour !   
First make sure that all static routes from previous labs are removed, then let's write some p4 entry reflecting `isis` convergence at `p4-core1` level:

      core1#sh ipv4 route v1                                                                                                            
      typ  prefix             metric  iface      hop       time
      I    1.1.1.0/24         115/9   ethernet0  10.0.1.1  00:11:49
      I    2.2.2.0/24         115/20  ethernet1  10.0.2.2  00:11:49
      C    10.0.1.0/24        0/0     ethernet0  null      00:00:28
      LOC  10.0.1.254/32      0/1     ethernet0  null      00:00:28
      C    10.0.2.0/24        0/0     ethernet1  null      00:00:28
      LOC  10.0.2.254/32      0/1     ethernet1  null      00:00:28
      I    10.1.1.1/32        115/9   ethernet0  10.0.1.1  00:11:49
      I    10.2.2.2/32        115/20  ethernet1  10.0.2.2  00:11:49
      C    10.254.254.254/32  0/0     loopback0  null      00:00:28

You identify by looking at `core1` ipv4 route table that 4 `isis` routes have to be programmed at `p4-core1` level after FreeRTR control plane has converged:

    # Entry corresponding to router control plane hw-mac address
    # P4 Object: tbl_ipv4_fib_host
    # Table key: 10.1.1.1
    # Action id: act_rmac_set_nexthop
    # Action params: {1}
    # Trigger: when core1 FreeRTR isis route is inserted into ipv4 table
    table_add tbl_ipv4_fib_host act_ipv4_set_nexthop 10.1.1.1 => 1

    # Entry corresponding to router control plane hw-mac address
    # P4 Object: tbl_ipv4_fib_host
    # Table key: 10.2.2.2
    # Action id: act_rmac_set_nexthop
    # Action params: {2}
    # Trigger: when core1 FreeRTR isis route is inserted into ipv4 table
    table_add tbl_ipv4_fib_host act_ipv4_set_nexthop 10.2.2.2 => 2

    # Entry corresponding to router control plane hw-mac address
    # P4 Object: tbl_ipv4_fib_host
    # Table key: 1.1.1.0/24
    # Action id: act_rmac_set_nexthop
    # Action params: {1}
    # Trigger: when core1 FreeRTR isis route is inserted into ipv4 table    
    table_add tbl_ipv4_fib_lpm act_ipv4_set_nexthop 1.1.1.0/24 => 1

    # Entry corresponding to router control plane hw-mac address
    # P4 Object: tbl_ipv4_fib_host
    # Table key: 2.2.2.0/24
    # Action id: act_rmac_set_nexthop
    # Action params: {2}
    # Trigger: when core1 FreeRTR isis route is inserted into ipv4 table
    table_add tbl_ipv4_fib_lpm act_ipv4_set_nexthop 2.2.2.0/24 => 2


# Lab verification
* On `cpe1`:
      cpe1#ping 10.2.2.2 /vrf v1 /interface lo0                                                                                         
      pinging 10.2.2.2, src=10.1.1.1, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=1/2/3/13
      cpe1#ping 2.2.2.2 /vrf v1 /interface lo1                                                                                          
      pinging 2.2.2.2, src=1.1.1.1, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/2/4/16
      cpe1#

* On `cpe2`:
      cpe2#ping 10.1.1.1 /vrf v1 /interface lo0                                                                                         
      pinging 10.1.1.1, src=10.2.2.2, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=1/1/2/8
      cpe2#ping 1.1.1.1 /vrf v1 /interface lo1                                                                                          
      pinging 1.1.1.1, src=2.2.2.2, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/3/6/15
      cpe2#                  

# Key take-away
* This labs put the focus on P4 code snippets necessary to enable `isis` operation.
* The parser mapped `LLC DSAP/SSAP` link layer using `0 &&& 0xfe00` and `0 &&& 0xfa00`.
* And isis mac {`09:00:2b:00:00:05`,`01:80:c2:00:00:14`,`01:80:c2:00:00:15`} are used to match `isis` control protocol packet
* Last but not least, this example works as `arp` mapping was statically applied at FreeRTR level on `cpe1` and `core1` with the `ipv4 host-static <ipv4-address> <hw-address>` command.

# Follow-ups
* It you pay attention carefully to this example, `tbl_nexthop` table has an action `act_ipv4_fib_hit` that is never triggered. (Thus ipv4 rewriting never occur). There should be a way to trigger `act_ipv4_fib_hit` as it should be.
   * Forwarding via a `vector metadata` will be the object of a subsequent lab. The `vector metadata` value will condition which action to trigger.
* Considering the previous section, this `arp` mapping must be dynamic especially in production environment.   
   * `L2 learning` will be the object of a subsequent Lab.
