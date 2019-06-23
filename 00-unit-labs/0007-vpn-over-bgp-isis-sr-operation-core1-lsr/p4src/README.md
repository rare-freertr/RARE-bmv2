# Lab topology
The topology used is common to all unit labs defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
# Lab title:
**VPN over BGP with ISIS IPv4 MPLS-SR as transport with `core1` as a pure LSR**
# Lab objective
In this lab we are using the [previous lab](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0006-ipv4-isis-sr-operation/p4src). (IPv4 Segment Routing with FreeRTR control plane).
* SR SID bindings is distributed by ISIS segment routing sub-TLV
* SR-MPLS as implied by the name  uses MPLS dataplane
* However, we create a `bgp` L3VPN on `cpe1` and `cpe2`
* And establish a VPNv4 peering between `cpe1` and `cpe2` in order to exchange VPNv4 NLRI.
* This `bgp` VPNv4 session is established using `loopback0` SR NODE SID.
* Reachability tests are from a `loopback2` on `cpe1` and `cpe2`.
* `loopback2` belong to a customer vrf c1
* Each routers has their `loopback0` that are advertised within ISIS as passive networks.
* `cpe1` ping `10.2.2.2` from `10.2.2.2/32` advertized by `cpe2`
* `cpe2` ping `10.1.1.1` from `10.1.1.1/32` advertized by `cpe1`
* Each customer `loopback2` is advertized via `bgp` using vpnv4 address-family (`vpnuni`).
* `cpe1` ping `10.100.200.2` from `10.100.100.1/32` advertized by `cpe1`
* `cpe2` ping `10.100.100.1` from `10.100.200.2/32` advertized by `cpe2`

* As the previous Lab we are re-using [`switch.p4`](https://github.com/p4lang/switch) pieces of code. The approach is to step by step learn also how `switch.p4` is structuring all the features a modern switch can include via P4 dataplane.

# Lab operation
* Run the reference Lab architecture defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
* Compile `isis-sr-operation` and launch `simple_switch`
```
cd ~/RARE/00-unit-labs/0007-vpn-over-bgp-isis-sr-operation-core1-lsr/p4src
make
```

# Control Plane operation
* Enable `MPLS forwarding` and `ISIS-SR` on `cpe1`, `core1`,`cpe2` routers
  * `cpe1`

        cpe1#sh run vrf defi c1
         vrf definition c1
          rd 1:2
          rt-import 1:2
          rt-export 1:2
          exit
        !  
        cpe1#sh run int lo2
          interface loopback2
           no description
           vrf forwarding c1
           ipv4 address 10.100.100.1 255.255.255.0
           no shutdown
           no log-link-change
           exit
        !
        router bgp4 1                                        
         vrf v1
         local-as 1
         router-id 10.1.1.1
         address-family vpnuni
         neighbor 10.2.2.2 remote-as 1
         neighbor 10.2.2.2 description lo0@cpe1 -> lo0@cpe2
         neighbor 10.2.2.2 local-as 1
         neighbor 10.2.2.2 address-family vpnuni
         neighbor 10.2.2.2 distance 200
         neighbor 10.2.2.2 update-source loopback0
         neighbor 10.2.2.2 send-community standard extended
         afi-vrf c1 enable
         afi-vrf c1 enable
         afi-vrf c1 redistribute connected
         exit
        !             

  * `cpe2`

        cpe2#sh run vrf def c1
        vrf definition c1
         rd 1:2
         rt-import 1:2
         rt-export 1:2
         exit
        !
        cpe2#sh run int lo2
        interface loopback2
         no description
         vrf forwarding c1
         ipv4 address 10.100.200.2 255.255.255.0
         no shutdown
         no log-link-change
         exit
        !
        router bgp4 1                                        
         vrf v1
         local-as 1
         router-id 10.2.2.2
         address-family vpnuni
         neighbor 10.1.1.1 remote-as 1
         neighbor 10.1.1.1 description lo0@cpe2 -> lo0@cpe1
         neighbor 10.1.1.1 local-as 1
         neighbor 10.1.1.1 address-family vpnuni
         neighbor 10.1.1.1 distance 200
         neighbor 10.1.1.1 update-source loopback0
         neighbor 10.1.1.1 send-community standard extended
         afi-vrf c1 enable
         afi-vrf c1 redistribute connected
         exit
        !
  * `core1`

        ! Same configuration as previous LAB (core1 is a pure LSP)
* Connect `p4-core1` via CLI:
```
simple_switch_CLI --thrift-port 9090
Obtaining JSON from switch...
Done
Control utility for runtime P4 table manipulation
RuntimeCmd:
```
* Program the entries in `tbl_nexthop` table  
In this lab we extended our `tbl_nexthop` by adding a key field that set the traffic priority. We use `switch.p4` trigger: `md.intrinsic_metadata.priority` set during `prs_set_prio_med` state.
    * `tlb_nexthop` rules for control traffic

          # Entry corresponding to nexthop reachability via port p4-core1-dp1
          # P4 Object: tbl_nexthop
          # Table key: 1 3
          # Action id: act_cpl_opr_fib_hit
          # Action params: {1}
          # Trigger: when core1 FreeRTR is booting up
          table_add tbl_nexthop act_cpl_opr_fib_hit 1 3 => 1

          # Entry corresponding to nexthop reachability via port p4-core1-dp2
          # P4 Object: tbl_nexthop
          # Table key: 2 3
          # Action id: act_cpl_opr_fib_hit
          # Action params: {2}
          # Trigger: when core1 FreeRTR is booting up
          table_add tbl_nexthop act_cpl_opr_fib_hit 2 3 => 2

          # Entry corresponding to nexthop reachability via port p4-core1-cpu1
          # P4 Object: tbl_nexthop
          # Table key: 255 3
          # Action id: act_cpl_opr_fib_hit
          # Action params: {255}
          # Trigger: when core1 FreeRTR is booting up
          table_add tbl_nexthop act_cpl_opr_fib_hit 255 3 => 255

          # Entry corresponding to nexthop reachability via port p4-core1-cpu2
          # P4 Object: tbl_nexthop
          # Table key: 254 3
          # Action id: act_cpl_opr_fib_hit
          # Action params: {254}
          # Trigger: when core1 FreeRTR is booting up
          table_add tbl_nexthop act_cpl_opr_fib_hit 254 3 => 254

  * `tlb_nexthop` rules for data plane/transient traffic

          # Entry corresponding to nexthop reachability via port p4-core1-dp1
          # P4 Object: tbl_nexthop
          # Table key: 1 0
          # Action id: act_ipv4_fib_hit
          # Action params: {00:00:0a:00:01:01 1}
          # Trigger: core1 arp learning activity
          table_add tbl_nexthop act_ipv4_fib_hit 1 0 =>  00:00:0a:00:01:01 1

          # Entry corresponding to nexthop reachability via port p4-core1-dp2
          # P4 Object: tbl_nexthop
          # Table key: 2 0
          # Action id: act_ipv4_fib_hit
          # Action params: {00:00:0a:00:02:02 2}
          # Trigger: core1 arp learning activity
          table_add tbl_nexthop act_ipv4_fib_hit 2 0 =>  00:00:0a:00:02:02 2

          # Entry corresponding to nexthop reachability via port p4-core1-cpu1
          # P4 Object: tbl_nexthop
          # Table key: 255 0
          # Action id: act_ipv4_fib_hit
          # Action params: {00:00:0a:00:01:fe 255}
          # Trigger: when core1 FreeRTR is booting up
          table_add tbl_nexthop act_ipv4_fib_hit 255 0 =>  00:00:0a:00:01:fe 255

          # Entry corresponding to nexthop reachability via port p4-core1-cpu2
          # P4 Object: tbl_nexthop
          # Table key: 254 0
          # Action id: act_ipv4_fib_hit
          # Action params: {00:00:0a:00:02:fe 254}
          # Trigger: when core1 FreeRTR is booting up
          table_add tbl_nexthop act_ipv4_fib_hit 254 0 =>  00:00:0a:00:02:fe 254


* Program the mac entries in `tbl_rmac_fib` table used in `isis` operation

      # Entry corresponding to ISIS control plane mac address
      # P4 Object: tbl_rmac_fib
      # Table key: 09:00:2b:00:00:05
      # Action id: act_rmac_set_nexthop
      # Action params: {}
      # Trigger: when core1 FreeRTR is enabling 1st isis adjacency
      table_add tbl_rmac_fib act_rmac_set_nexthop 09:00:2b:00:00:05 =>

      # Entry corresponding to ISIS control plane hw-mac address
      # P4 Object: tbl_rmac_fib
      # Table key: 01:80:c2:00:00:15
      # Action id: act_rmac_set_nexthop
      # Action params: {}
      # Trigger: when core1 FreeRTR is enabling 1st isis adjacency
      table_add tbl_rmac_fib act_rmac_set_nexthop 01:80:c2:00:00:15 =>

      # Entry corresponding to ISIS control plane hw-mac address
      # P4 Object: tbl_rmac_fib
      # Table key: 01:80:c2:00:00:14
      # Action id: act_rmac_set_nexthop
      # Action params: {}
      # Trigger: when core1 FreeRTR is enabling 1st isis adjacency
      table_add tbl_rmac_fib act_rmac_set_nexthop 01:80:c2:00:00:14 =>

* Ensure IGP peers reachability from `p4-core1` perspective:
   * `tbl_ipv4_fib_host` rules
         # Entry corresponding to router IPv4 address
         # P4 Object: tbl_ipv4_fib_host
         # Table key: 10.1.1.1
         # Action id: act_ipv4_set_nexthop
         # Action params: {1}
         # Trigger: ISIS convergence
         table_add tbl_ipv4_fib_host act_ipv4_set_nexthop 10.1.1.1 => 1

         # Entry corresponding to router IPv4 address
         # P4 Object: tbl_ipv4_fib_host
         # Table key: 10.0.1.1
         # Action id: act_ipv4_set_nexthop
         # Action params: {1}
         # Trigger: core1 arp learning activity
         table_add tbl_ipv4_fib_host act_ipv4_set_nexthop 10.0.1.1 => 1

         # Entry corresponding to router IPv4 address
         # P4 Object: tbl_ipv4_fib_host
         # Table key: 10.254.254.254
         # Action id: act_ipv4_set_nexthop
         # Action params: {255}
         # Trigger: core1 boots up and interface is configured
         table_add tbl_ipv4_fib_host act_ipv4_set_nexthop 10.254.254.254 => 255

         # Entry corresponding to router IPv4 address
         # P4 Object: tbl_ipv4_fib_host
         # Table key: 10.0.1.254
         # Action id: act_ipv4_set_nexthop
         # Action params: {255}
         # Trigger: core1 boots up and interface is configured
         table_add tbl_ipv4_fib_host act_ipv4_set_nexthop 10.0.1.254 => 255

         # Entry corresponding to router IPv4 address
         # P4 Object: tbl_ipv4_fib_host
         # Table key: 10.0.2.254
         # Action id: act_ipv4_set_nexthop
         # Action params: {254}
         # Trigger: core1 boots up and interface is configured
         table_add tbl_ipv4_fib_host act_ipv4_set_nexthop 10.0.2.254 => 254

         # Entry corresponding to router IPv4 address
         # P4 Object: tbl_ipv4_fib_host
         # Table key: 10.2.2.2
         # Action id: act_ipv4_set_nexthop
         # Action params: {2}
         # Trigger: ISIS convergence
         table_add tbl_ipv4_fib_host act_ipv4_set_nexthop 10.2.2.2 => 2

         # Entry corresponding to router IPv4 address
         # P4 Object: tbl_ipv4_fib_host
         # Table key: 10.0.2.2
         # Action id: act_ipv4_set_nexthop
         # Action params: {2}
         # Trigger: core1 arp learning activity
         table_add tbl_ipv4_fib_host act_ipv4_set_nexthop 10.0.2.2 => 2

  * `tbl_ipv4_fib_lpm` rules
         # Entry corresponding to router IPv4 subnet prefix
         # P4 Object: tbl_ipv4_fib_lpm
         # Table key: 1.1.1.0/24
         # Action id: act_ipv4_set_nexthop
         # Action params: {1}
         # Trigger: ISIS convergence
         table_add tbl_ipv4_fib_lpm act_ipv4_set_nexthop 1.1.1.0/24 => 1

         # Entry corresponding to router IPv4 subnet prefix
         # P4 Object: tbl_ipv4_fib_lpm
         # Table key: 2.2.2.0/24
         # Action id: act_ipv4_set_nexthop
         # Action params: {2}
         # Trigger: ISIS convergence         
         table_add tbl_ipv4_fib_lpm act_ipv4_set_nexthop 2.2.2.0/24 => 2

         # Entry corresponding to router IPv4 subnet prefix
         # P4 Object: tbl_ipv4_fib_lpm
         # Table key: 6.6.6.0/24
         # Action id: act_ipv4_set_nexthop
         # Action params: {255}
         # Trigger: ISIS convergence
         table_add tbl_ipv4_fib_lpm act_ipv4_set_nexthop 6.6.6.0/24 => 255


* At this point ISIS-SR operation is enabled:

 * `cpe1`
        cpe1#sh mpls for                                                                                                                  
        label    vrf   iface      hop         label       targets  bytes
        105839   v1:4  ethernet0  10.0.1.254  158476               0
        376722   v1:4  ethernet0  10.0.1.254  unlabelled           0
        475753   c1:4  null       null        unlabelled  local    1380
        697699   v1:4  null       null        unlabelled  pwe      0
        821486   v1:4  ethernet0  10.0.1.254  unlabelled           0
        854214   v1:4  null       null        unlabelled  pwe      0
        859180   v1:4  null       null        unlabelled  local    0
        864861   v1:4  ethernet0  10.0.1.254  158477               0
        894748   null  null       null        unlabelled           0
        894749   v1:4  null       null        unlabelled  local    22045
        894750   v1:4  ethernet0  10.0.1.254  158476               0
        894751   v1:4  ethernet0  10.0.1.254  158477               0
        894752   null  null       null        unlabelled           0
        894753   null  null       null        unlabelled           0
        894754   null  null       null        unlabelled           0
        894755   null  null       null        unlabelled           0
        894756   null  null       null        unlabelled           0
        894757   null  null       null        unlabelled           0
        903878   v1:4  ethernet0  10.0.1.254  3                    0
        911010   c1:6  null       null        unlabelled  local    0
        986954   v1:4  ethernet0  10.0.1.254  unlabelled           0
        1044835  v1:6  null       null        unlabelled  local    0                                                           
        !
        cpe1#sh ipv4 route v1 10.2.2.2 | i seg                                                                                            
        segment routing index = 3
        segment routing old base = 336976
        segment routing base = 158474
        segment routing size = 0

 * `cpe2`

        cpe2#sh mpls for                                                                                                                  
        label   vrf   iface      hop         label       targets  bytes
        210907  v1:4  ethernet0  10.0.2.254  3                    0
        253581  v1:4  ethernet0  10.0.2.254  158476               0
        336976  null  null       null        unlabelled           0
        336977  v1:4  ethernet0  10.0.2.254  158475               0
        336978  v1:4  ethernet0  10.0.2.254  158476               0
        336979  v1:4  null       null        unlabelled  local    36830
        336980  null  null       null        unlabelled           0
        336981  null  null       null        unlabelled           0
        336982  null  null       null        unlabelled           0
        336983  null  null       null        unlabelled           0
        336984  null  null       null        unlabelled           0
        336985  null  null       null        unlabelled           0
        344400  v1:4  ethernet0  10.0.2.254  unlabelled           0
        368158  v1:4  null       null        unlabelled  local    0
        602250  v1:4  ethernet0  10.0.2.254  unlabelled           0
        607114  v1:4  ethernet0  10.0.2.254  158475               0
        654495  v1:4  null       null        unlabelled  pwe      0
        765508  v1:4  null       null        unlabelled  pwe      0
        854406  c1:4  null       null        unlabelled  local    1840
        888744  c1:6  null       null        unlabelled  local    0
        939344  v1:6  null       null        unlabelled  local    0
        973189  v1:4  ethernet0  10.0.2.254  unlabelled           0

        cpe2#sh ipv4 route v1 10.1.1.1 | i seg                                                                                            
        segment routing index = 1
        segment routing old base = 894748
        segment routing base = 158474
        segment routing size = 0

 * `core1`

        core1#sh mpls for                                                                                                                 
        label   vrf   iface      hop       label       targets  bytes
        9186    v1:4  ethernet1  10.0.2.2  3                    0
        158474  null  null       null      unlabelled           0
        158475  v1:4  ethernet0  10.0.1.1  894749               0
        158476  v1:4  null       null      unlabelled  local    0
        158477  v1:4  ethernet1  10.0.2.2  336979               0
        158478  null  null       null      unlabelled           0
        158479  null  null       null      unlabelled           0
        158480  null  null       null      unlabelled           0
        158481  null  null       null      unlabelled           0
        158482  null  null       null      unlabelled           0
        158483  null  null       null      unlabelled           0
        423166  v1:4  ethernet0  10.0.1.1  unlabelled           0
        518679  c1:6  null       null      unlabelled  local    0
        534495  c1:4  null       null      unlabelled  local    0
        626505  v1:4  ethernet1  10.0.2.2  unlabelled           0
        762773  v1:4  null       null      unlabelled  local    0
        821978  v1:4  ethernet0  10.0.1.1  894749               0
        873408  v1:6  null       null      unlabelled  local    0
        874469  v1:4  ethernet1  10.0.2.2  336979               0
        987397  v1:4  ethernet0  10.0.1.1  3                    0               

* But forwarding does not occur even if `core1` control plane `isis-sr` converged.
```
cpe1#ping 10.2.2.2 /vrf v1 /interface lo0                                                                                         
pinging 10.2.2.2, src=10.1.1.1, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
.....
result=0%, recv/sent/lost=0/5/5, rtt min/avg/max/total=10000/0/0/5009
cpe1#                                                                       
```
* Also VPNv4 session between `cpe1` and `cpe2` is `down`

No worry... This is again an expected behaviour !  
If you notice just right after ISIS convergence, `ping` tests were successful. After SR activation and convergence, connectivity is again "broken" as it was the case for LDP. The reason is that now the traffic is MPLS encapsulated and is not recognized by `p4-core1`.

However, there is one big difference between LDP. In SR case, MPLS encapsulation include only the NODE SID. (i.e `10.1.1.1`, `10.254.254.254`,`10.2.2.2`) While LDP was allocation for each IPv4 FEC.

Let's write some P4 rules based on `core1` MPLS forwarding and SR information in order to enable `bgp` VPNv4 establishment:
    # Entry corresponding to Label swap operation from core1
    # at P4 level (label swap) for FEC to cpe1.
    # This is a the case as FreeRTR is performing label swap at the p4-core1 level
    # P4 Object: tbl_mpls_fib
    # Table key: 972513
    # Action id: act_mpls_swap_set_nexthop
    # Action params: {930982 2}
    # Trigger: when core1 FreeRTR ISIS-SR has converged             
    table_add tbl_mpls_fib act_mpls_swap_set_nexthop 158477 => 336979 2

    # Entry corresponding to Label swap operation from core1
    # at P4 level (label swap) for FEC to cpe2.
    # This is a the case as FreeRTR is performing label swap at the p4-core1 level
    # P4 Object: tbl_mpls_fib
    # Table key: 972511
    # Action id: act_mpls_swap_set_nexthop
    # Action params: {662376 1}
    # Trigger: when core1 FreeRTR ISIS-SR has converged                 
    table_add tbl_mpls_fib act_mpls_swap_set_nexthop 158475 => 894749 1

# Lab verification
* On `cpe1`

      cpe1#ping 10.2.2.2 /vrf v1 /interface lo0                                                                                         
      pinging 10.2.2.2, src=10.1.1.1, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=1/2/3/13
      cpe1#
      cpe1#ping 10.100.200.2 /vrf c1 /interface lo2
      pinging 10.100.200.2, src=10.100.100.1, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=1/2/4/11
      cpe1#                                                                                       

* On `cpe2`

      cpe2#ping 10.1.1.1 /vrf v1 /interface lo0                                                                                         
      pinging 10.1.1.1, src=10.2.2.2, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=1/1/2/8
      cpe2#                  
      cpe2#ping  10.100.100.1 /vrf c1 /int lo2
      pinging 10.100.100.1, src=10.100.200.2, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=1/2/3/14
      cpe2#                                                                                        

* IMPORTANT observations:    
 * `ping` is working for `lo0` and `lo2`
 * Both of these traffic are encapsulated with MPLS
 * `lo0` reachability test has a MPLS header with a label stack which size is 1. (forwarding label)
 * `lo2` reachability test has a MPLS header with a label stack which is is 2. (forwarding label, VPN label)

# Key take-away
* This labs put the focus on FreeRTR CLI snippets necessary to enable VPN over `bgp` with ISIS-SR transport.
* At P4 level, the code is stricly identical to [ISIS SR Lab](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0006-ipv4-isis-sr-operation/p4src).
* By default, FreeRTR is not performing PHP so decapsulation action is never triggered
* By default, FreeRTR is performing `bgp nexthop-self`
* SR continue (MPLS swap) is triggered here, MPLS Encapsulation/Decapsulation is not tested here
* Again, MPLS forwarding is effective only for the NODE SID(s).

# Follow-ups
* At this stage, we have a router that has MPLS P functions with MPLS-SR transport.
   * `core1` is acting a a pure LSR
   * `core1` is transporting L3VPN traffic signalled by `bgp` using `lo0` (NODE SID)
   * Next step is to test `core1` as ingress, egress LER
