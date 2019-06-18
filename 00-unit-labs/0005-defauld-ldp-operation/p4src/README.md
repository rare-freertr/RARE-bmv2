# Lab topology
The topology used is common to all unit labs defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
# Lab title:
**Default LDP operation**
# Lab objective
This lab objective is to identify the P4 code at the dataplane level (parser, table entries etc.) necessary to enable default LDP operation with FreeRTR control plane.
* LDP rely on the IGP in order to generate a label binding per FEC in the routing table.
 * Hence, this lab is based on the previous optimized version of basic IPv4 forwarding with ISIS P4 program described in a [previous lab](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0004-isis-operation/p4src) with additional code
* Reachability tests are from `cpe1`, `core1` and `cpe2`.
* Each routers has their `loopback0` that are advertised within ISIS as passive networks.
* `cpe1` ping `10.2.2.2` from `10.2.2.2/32` advertized by `cpe2`
* `cpe1` ping `2.2.2.2` from `2.2.2.0/24` advertized by `cpe2`
* `cpe1` ping `10.254.254.254` from `10.254.254.254/32` advertized by `core1`
* `cpe1` ping `6.6.6.6` from `6.6.6.0/24` advertized by `core1`
* `cpe2` ping `10.1.1.1` from `10.1.1.1/32` advertized by `cpe1`
* `cpe2` ping `1.1.1.1` from `1.1.1.0/24` advertized by `cpe1`
* `cpe2` ping `10.254.254.254` from `10.254.254.254/32` advertized by `core1`
* `cpe2` ping `6.6.6.6` from `6.6.6.0/24` advertized by `core1`
* `core1` ping `10.2.2.2` from `10.2.2.2/32` advertized by `cpe2`
* `core1` ping `2.2.2.2` from `2.2.2.0/24` advertized by `cpe2`
* `core1` ping `10.1.1.1` from `10.1.1.1/32` advertized by `cpe1`
* `core1` ping `1.1.1.1` from `1.1.1.0/24` advertized by `cpe1`
* As the previous Lab we are re-using [`switch.p4`](https://github.com/p4lang/switch) pieces of code. The approach is to step by step learn also how `switch.p4` is structuring all the features a modern switch can include via P4 dataplane.

* Default LDP operation:
   * By default, LDP uses `all router` multicast address (mac:`01:00:5e:00:00:02` IP:`224.0.0.2`)
   * It uses `UDP port 646` and `TCP port 646` for `discovery`/`session`/`advertisement` and `notification` messages
   * FreeRTR is generating a label binding for each FEC in the IPv4 / IPv6 route table
   * Reachability toward IPv4/IPv6 IP addresses used to source LDP traffic must be enabled
   * FreeRTR is not performing PHP so the packet decapsulation occur at the last egress LSR of the LSP.
   * During the tests in this LAB, FreeRTR `cpe1` and `cpe2` are performing MPLS encapsulation at the LSP ingress, this means that `p4-core1` will only have to handle swap label operation.

# Lab operation
* Run the reference Lab architecture defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
* Compile `defauld-ldp-operation.p4` and launch `simple_switch`
```
cd ~/RARE/00-unit-labs/0005-defauld-ldp-operation/p4src
make
```

# Control Plane operation
* Enable `MPLS forwarding` and `LDP` on `cpe1`, `core1`,`cpe2` routers
  * `cpe1`

        cpe1#sh run int eth0
        interface ethernet0
         no description
         macaddr 0000.0a00.0101
         vrf forwarding v1
         ipv4 address 10.0.1.1 255.255.255.0
         ipv4 host-static 10.0.1.254 0000.0a00.01fe
         mpls enable
         mpls ldp4
         router isis4 1 enable
         router isis4 1 circuit both
         no shutdown
         no log-link-change
         exit
         !
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
        cpe1#sh run int lo1                
        interface loopback1                
         no description                    
         vrf forwarding v1                 
         ipv4 address 1.1.1.1 255.255.255.0
         router isis4 1 enable             
         router isis4 1 passive            
         router isis4 1 circuit both       
         no shutdown                       
         no log-link-change                
         exit                              
        !                                  
  * `cpe2`

        cpe2#sh run int eth0
        interface ethernet0
         no description
         macaddr 0000.0a00.0202
         vrf forwarding v1
         ipv4 address 10.0.2.2 255.255.255.0
         ipv4 host-static 10.0.2.254 0000.0a00.02fe
         mpls enable
         mpls ldp4
         router isis4 1 enable
         router isis4 1 circuit both
         no shutdown
         no log-link-change
         exit
        !
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
        interface loopback1                 
         no description                     
         vrf forwarding v1                  
         ipv4 address 2.2.2.2 255.255.255.0
         router isis4 1 enable              
         router isis4 1 passive             
         router isis4 1 circuit both        
         no shutdown                        
         no log-link-change                 
         exit                               
        !                                   

  * `core1`

        core1#sh run int eth0
         interface ethernet0
         no description
         macaddr 0000.0a00.01fe
         vrf forwarding v1
         ipv4 address 10.0.1.254 255.255.255.0
         ipv4 host-static 10.0.1.1 0000.0a00.0101
         mpls enable
         mpls ldp4
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
         mpls enable
         mpls ldp4
         router isis4 1 enable
         router isis4 1 circuit both
         no shutdown
         no log-link-change
         exit
        !
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
        core1#sh run int lo1                 
        interface loopback1                  
         no description                      
         vrf forwarding v1                   
         ipv4 address 6.6.6.6 255.255.255.0  
         router isis4 1 enable               
         router isis4 1 passive              
         router isis4 1 circuit both         
         no shutdown                         
         no log-link-change                  
         exit                                
        !                                                                        
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

* Program the mac entry in `tbl_ipv4_fib_host` table used in `ldp` discovery operation

      # Entry corresponding to all router multicast address
      # P4 Object: tbl_ipv4_fib_host
      # Table key: 224.0.0.2
      # Action id: act_ipv4_cpl_set_nexthop
      # Action params: {}
      # Trigger: when core1 FreeRTR is enabling 1st ldp interface
      table_add tbl_ipv4_fib_host act_ipv4_cpl_set_nexthop 224.0.0.2 =>

* Ensure ldp peers (sourcing ldp packet) reachability from `p4-core1` perspective:
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


* At this point LDP operation is enabled:

 * `cpe1`

        cpe1#show ipv4 ldp v1 summary                                                                                                     
        learn  advert  l2learn  l2advert  mplearn  mpadvert  neighbor    uptime
        11     10      0        0         0        0         10.0.1.254  04:09:08

        cpe1#show ipv4 ldp v1 database                                                                                                    
        prefix             local   remote  hop
        1.1.1.0/24         239026          null
        1.1.1.1/32         239026          null
        2.2.2.0/24         416254  805394  10.0.1.254
        6.6.6.0/24         330183  259412  10.0.1.254
        10.0.1.0/24        239026          null
        10.0.1.1/32        239026          null
        10.0.2.0/24        868238  259412  10.0.1.254
        10.1.1.1/32        239026          null
        10.2.2.2/32        733364  949257  10.0.1.254
        10.254.254.254/32  696195  259412  10.0.1.254

        cpe1#show mpls forwarding                                                                                                         
        label   vrf   iface      hop         label       targets  bytes
        239026  v1:4  null       null        unlabelled  local    924600
        330183  v1:4  ethernet0  10.0.1.254  259412               0
        416254  v1:4  ethernet0  10.0.1.254  805394               0
        686991  v1:6  null       null        unlabelled  local    0
        696195  v1:4  ethernet0  10.0.1.254  259412               0
        733364  v1:4  ethernet0  10.0.1.254  949257               0
        868238  v1:4  ethernet0  10.0.1.254  259412               0
 * `cpe2`

        cpe2#show ipv4 ldp v1 summary                                                                                                     
        learn  advert  l2learn  l2advert  mplearn  mpadvert  neighbor    uptime
        11     10      0        0         0        0         10.0.2.254  02:10:18

        cpe2#show ipv4 ldp v1 database                                                                                                    
        prefix             local   remote  hop
        1.1.1.0/24         432634  403802  10.0.2.254
        2.2.2.0/24         150848          null
        2.2.2.2/32         150848          null
        6.6.6.0/24         376969  259412  10.0.2.254
        10.0.1.0/24        119590  259412  10.0.2.254
        10.0.2.0/24        150848          null
        10.0.2.2/32        150848          null
        10.1.1.1/32        409375  232728  10.0.2.254
        10.2.2.2/32        150848          null
        10.254.254.254/32  951035  259412  10.0.2.254

        cpe2#show mpls forwarding                                                                                                         
        label   vrf   iface      hop         label       targets  bytes
        119590  v1:4  ethernet0  10.0.2.254  259412               0
        150848  v1:4  null       null        unlabelled  local    6440
        376969  v1:4  ethernet0  10.0.2.254  259412               0
        409375  v1:4  ethernet0  10.0.2.254  232728               0
        427301  v1:6  null       null        unlabelled  local    0
        432634  v1:4  ethernet0  10.0.2.254  403802               0
        951035  v1:4  ethernet0  10.0.2.254  259412               0
 * `core1`

        core1#show ipv4 ldp v1 summary                                                                                                    
        learn  advert  l2learn  l2advert  mplearn  mpadvert  neighbor  uptime
        10     11      0        0         0        0         10.0.1.1  04:12:18
        10     11      0        0         0        0         10.0.2.2  02:11:34

        core1#show ipv4 ldp v1 database                                                                                                   
        prefix             local   remote  hop
        1.1.1.0/24         403802  239026  10.0.1.1
        2.2.2.0/24         805394  150848  10.0.2.2
        6.6.6.0/24         259412          null
        6.6.6.6/32         259412          null
        10.0.1.0/24        259412          null
        10.0.1.254/32      259412          null
        10.0.2.0/24        259412          null
        10.0.2.254/32      259412          null
        10.1.1.1/32        232728  239026  10.0.1.1
        10.2.2.2/32        949257  150848  10.0.2.2
        10.254.254.254/32  259412          null

        core1#show mpls forwarding                                                                                                        
        label   vrf   iface      hop       label       targets  bytes
        49866   v1:6  null       null      unlabelled  local    0
        232728  v1:4  ethernet0  10.0.1.1  239026               0
        259412  v1:4  null       null      unlabelled  local    925520
        403802  v1:4  ethernet0  10.0.1.1  239026               0
        805394  v1:4  ethernet1  10.0.2.2  150848               0
        949257  v1:4  ethernet1  10.0.2.2  150848               0

* But forwarding does not occur even if `core1` control plane `isis` and `ldp` converged.
```
cpe1#ping 10.2.2.2 /vrf v1 /interface lo0                                                                                         
pinging 10.2.2.2, src=10.1.1.1, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
.....
result=0%, recv/sent/lost=0/5/5, rtt min/avg/max/total=10000/0/0/5009
cpe1#                                                                       
```

No worry... This is again an expected behaviour !  
If you notice just right after ISIS convergence, `ping` tests were successful. After LDP activation and convergence, connectivity is again "broken". The reason is that now the traffic is MPLS encapsulated and is not recognized by `p4-core1`. Let's take a look at the `tcpdump` output:
```
sudo tcpdump -ven --immediate-mode  -i p4-core1-dp1 mpls

13:53:37.469518 00:00:0a:00:01:01 > 00:00:0a:00:01:fe, ethertype MPLS unicast (0x8847), length 110: MPLS (label 805394, exp 0, [S], ttl 255)
        (tos 0x0, ttl 254, id 13101, offset 0, flags [none], proto ICMP (1), length 92)
    1.1.1.1 > 2.2.2.2: ICMP echo request, id 0, seq 17539, length 72
13:53:38.470106 00:00:0a:00:01:01 > 00:00:0a:00:01:fe, ethertype MPLS unicast (0x8847), length 110: MPLS (label 805394, exp 0, [S], ttl 255)
        (tos 0x0, ttl 254, id 13102, offset 0, flags [none], proto ICMP (1), length 92)
    1.1.1.1 > 2.2.2.2: ICMP echo request, id 0, seq 17540, length 72
13:53:39.470485 00:00:0a:00:01:01 > 00:00:0a:00:01:fe, ethertype MPLS unicast (0x8847), length 110: MPLS (label 805394, exp 0, [S], ttl 255)
```

If you look at `p4-core-dp2`, there is no outgoing traffic. This is expexted as there is no rules that instruct `p4-core1` how to process MPLS packets.  
```
sudo tcpdump -ven --immediate-mode  -i p4-core1-dp2 mpls

```

Let's write some P4 rules based on `core1` LDP database:
    # Entry corresponding to Label imposition from core1
    # at P4 level (swap against itself) for FEC to cpe1
    # This is a special case as FreeRTR is performing label imposition at control plane level
    # P4 Object: tbl_mpls_fib
    # Table key: 239026
    # Action id: act_mpls_swap_set_nexthop
    # Action params: {239026 1}
    # Trigger: when core1 FreeRTR LDP has converged
    table_add tbl_mpls_fib act_mpls_swap_set_nexthop 239026 => 239026 1

    # Entry corresponding to Label imposition from core1
    # at P4 level (swap against itself) for FEC to core1 .
    # This is a special case as FreeRTR is performing label imposition at control plane level
    # P4 Object: tbl_mpls_fib
    # Table key:
    # Action id: act_mpls_swap_set_nexthop
    # Action params: {259412 255}
    # Trigger: when core1 FreeRTR LDP has converged    
    table_add tbl_mpls_fib act_mpls_swap_set_nexthop 259412 => 259412 255

    # Entry corresponding to Label imposition from core1
    # at P4 level (swap against itself) for FEC to cpe2 .
    # This is a special case as FreeRTR is performing label imposition at control plane level
    # P4 Object: tbl_mpls_fib
    # Table key: 150848
    # Action id: act_mpls_swap_set_nexthop
    # Action params: {150848 2}
    # Trigger: when core1 FreeRTR LDP has converged        
    table_add tbl_mpls_fib act_mpls_swap_set_nexthop 150848 => 150848 2

    # Entry corresponding to Label swap operation from core1
    # at P4 level (label swap) for FEC to cpe1.
    # This is a the case as FreeRTR is performing label swap at the p4-core1 level
    # P4 Object: tbl_mpls_fib
    # Table key: 403802
    # Action id: act_mpls_swap_set_nexthop
    # Action params: {239026 1}
    # Trigger: when core1 FreeRTR LDP has converged             
    table_add tbl_mpls_fib act_mpls_swap_set_nexthop 403802 => 239026 1

    # Entry corresponding to Label swap operation from core1
    # at P4 level (label swap) for FEC to cpe2.
    # This is a the case as FreeRTR is performing label swap at the p4-core1 level
    # P4 Object: tbl_mpls_fib
    # Table key: 805394
    # Action id: act_mpls_swap_set_nexthop
    # Action params: {150848 2}
    # Trigger: when core1 FreeRTR LDP has converged                 
    table_add tbl_mpls_fib act_mpls_swap_set_nexthop 805394 => 150848 2

    # Entry corresponding to Label swap operation from core1
    # at P4 level (label swap) for FEC to cpe1.
    # This is a the case as FreeRTR is performing label swap at the p4-core1 level
    # P4 Object: tbl_mpls_fib
    # Table key: 232728
    # Action id: act_mpls_swap_set_nexthop
    # Action params: {239026 1}
    # Trigger: when core1 FreeRTR LDP has converged                      
    table_add tbl_mpls_fib act_mpls_swap_set_nexthop 232728 => 239026 1

    # Entry corresponding to Label swap operation from core1
    # at P4 level (label swap) for FEC to cpe2.
    # This is a the case as FreeRTR is performing label swap at the p4-core1 level
    # P4 Object: tbl_mpls_fib
    # Table key: 949257
    # Action id: act_mpls_swap_set_nexthop
    # Action params: {150848 2}
    # Trigger: when core1 FreeRTR LDP has converged                          
    table_add tbl_mpls_fib act_mpls_swap_set_nexthop 949257 => 150848 2

# Lab verification
* On `cpe1`

      cpe1#ping 10.2.2.2 /vrf v1 /interface lo0                                                                                         
      pinging 10.2.2.2, src=10.1.1.1, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=1/2/3/13
      cpe1#ping 2.2.2.2 /vrf v1 /interface lo1                                                                                          
      pinging 2.2.2.2, src=1.1.1.1, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/2/4/16
      cpe1#

* On `cpe2`

      cpe2#ping 10.1.1.1 /vrf v1 /interface lo0                                                                                         
      pinging 10.1.1.1, src=10.2.2.2, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=1/1/2/8
      cpe2#ping 1.1.1.1 /vrf v1 /interface lo1                                                                                          
      pinging 1.1.1.1, src=2.2.2.2, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/3/6/15
      cpe2#                  

* On `core1`
      core1#ping 1.1.1.1 /vrf v1 /interface lo1                                         
      pinging 1.1.1.1, src=6.6.6.6, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!                                                                             
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/2/4/15                 

      pinging 10.1.1.1, src=10.254.254.254, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!                                                                                      
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/2/3/14                          
      core1#                                                                              
      core1#ping 2.2.2.2 /vrf v1 /interface lo1                                                  
      pinging 2.2.2.2, src=6.6.6.6, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false         
      !!!!!                                                                                      
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/2/4/17                          
      core1#                                                                                                                               
      core1#ping 10.2.2.2 /vrf v1 /interface lo0                                                 
      pinging 10.2.2.2, src=10.254.254.254, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
      !!!!!                                                                                      
      result=100%, recv/sent/lost=5/5/0, rtt min/avg/max/total=2/3/5/16                          
      core1#                                                                                           

# Key take-away
* This labs put the focus on P4 code snippets necessary to enable default LDP operation with FreeRTR.
* LDP rely on IGP in order to build the label bindings, we use `isis` [previous Lab](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0004-isis-operation/p4src) as underlying IGP.
* The parser parse layer 4 information in order to build metadata with LDP information for further processing
* LDP discovery packets are matched using well know `all router` multicast address `224.0.0.2`
* Other LDP messages packets are matched using LDP source IP address learned via `arp`
* FreeRTR is not performing PHP so decapsulation action is never triggered
* There is a particular case where `core1` is encapsulating packets at the control plane level. This correspond to a swap at P4 level using the same label as ingress / egress label. (A better solution would be to match is the ingress/egress port is a control plane port just send to the corresponding CPU port without any modification of the packets)
* Last but not least, this example works as `arp` mapping was statically applied at FreeRTR level on `cpe1` and `core1` with the `ipv4 host-static <ipv4-address> <hw-address>` command.

# Follow-ups
* At this stage, we have a router that has core MPLS P functions.
   * However, essential features are missing. Features like router ACL or basic Control Plane protection will be the object of subsequent Labs.
* Considering the previous section, this `arp` mapping must be dynamic especially in production environment.   
   * `L2 learning` will be the object of a subsequent Lab.
