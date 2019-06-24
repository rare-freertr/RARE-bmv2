# Lab topology
The topology used is common to all unit labs defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
# Lab title:
**ISIS IPv4 MPLS-SR operation**
# Lab objective
This lab objective is to identify the P4 code at the dataplane level (parser, table entries etc.) necessary to enable ISIS IPv4 Segement Routing with FreeRTR control plane.
* SR SID bindings is distributed by ISIS segment routing sub-TLV
* SR-MPLS as implied by the name  uses MPLS dataplane
* Hence, this lab is based on the previous LDP [previous lab](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0004-isis-operation/p4src) with additional code
* Reachability tests are from `cpe1`, `core1` and `cpe2`.
* Each routers has their `loopback0` that are advertised within ISIS as passive networks.
* `cpe1` ping `10.2.2.2` from `10.2.2.2/32` advertized by `cpe2`
* `cpe1` ping `10.254.254.254` from `10.254.254.254/32` advertized by `core1`
* `cpe2` ping `10.1.1.1` from `10.1.1.1/32` advertized by `cpe1`
* `cpe2` ping `10.254.254.254` from `10.254.254.254/32` advertized by `core1`
* `core1` ping `10.2.2.2` from `10.2.2.2/32` advertized by `cpe2`
* `core1` ping `10.1.1.1` from `10.1.1.1/32` advertized by `cpe1`
* As the previous Lab we are re-using [`switch.p4`](https://github.com/p4lang/switch) pieces of code. The approach is to step by step learn also how `switch.p4` is structuring all the features a modern switch can include via P4 dataplane.

* ISIS SR operation the same as integrated ISIS:
   * Parser still needs to parse LLC header
   * ISIS uses 3 multicast mac address: 09:00:2b:00:00:05, 01:80:c2:00:00:15, 01:80:c2:00:00:14  
   * FreeRTR is generating a label binding only for NODE SID in the IPv4 / IPv6 route table
   * SR is using MPLS dataplane, [SR push, SR continue, SR next] correspond to [MPLS push, MPLS swap, MPLS pop] operation
   * FreeRTR is not performing PHP so the packet decapsulation occur at the last egress LSR of the LSP. (SR uses MPLS dataplane)
   * During the tests in this LAB, FreeRTR `cpe1` and `cpe2` are performing MPLS encapsulation at the LSP ingress, this means that `p4-core1` will only have to handle swap label operation.

# Lab operation
* Run the reference Lab architecture defined [here](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0000-topology).
* Compile `isis-sr-operation` and launch `simple_switch`
```
cd ~/RARE/00-unit-labs/0006-isis-sr-operation/p4src
make
```

# Control Plane operation
* Enable `MPLS forwarding` and `ISIS-SR` on `cpe1`, `core1`,`cpe2` routers
  * `cpe1`

        cpe1#sh run router isis4 1
        router isis4 1                   
         vrf v1                          
         net-id 49.0001.0000.0a01.0101.00
         traffeng-id ::                  
         is-type level1                  
         segrout 10                      
         level1 segrout                  
         exit
         !       
        cpe1#sh run int eth0                     
        interface ethernet0
         no description
         macaddr 0000.0a00.0101
         vrf forwarding v1
         ipv4 address 10.0.1.1 255.255.255.0
         ipv4 host-static 10.0.1.254 0000.0a00.01fe
         mpls enable
         router isis4 1 enable
         router isis4 1 circuit level1
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
         router isis4 1 circuit level1  
         router isis4 1 segrout index 1
         router isis4 1 segrout node                    
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
         router isis4 1 circuit level1  
         no shutdown                       
         no log-link-change                
         exit                              
        !                                  
  * `cpe2`

        cpe2#sh run router isis4 1       
        router isis4 1                   
         vrf v1                          
         net-id 49.0001.0000.0a02.0202.00
         traffeng-id ::                  
         is-type level1                  
         segrout 10                      
         level1 segrout                  
         exit                            
        !
        cpe2#sh run int eth0
        interface ethernet0
         no description
         macaddr 0000.0a00.0202
         vrf forwarding v1
         ipv4 address 10.0.2.2 255.255.255.0
         ipv4 host-static 10.0.2.254 0000.0a00.02fe
         mpls enable
         router isis4 1 enable
         router isis4 1 circuit level1
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
         router isis4 1 circuit level1  
         router isis4 1 segrout index 1
         router isis4 1 segrout node                    
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

        core1#sh run router isis4 1      
        router isis4 1                   
         vrf v1                          
         net-id 49.0001.0000.0afe.fefe.00
         traffeng-id ::                  
         is-type level1                  
         segrout 10                      
         level1 segrout                  
         exit                            
        !
        core1#sh run int eth0                                   
         interface ethernet0
         no description
         macaddr 0000.0a00.01fe
         vrf forwarding v1
         ipv4 address 10.0.1.254 255.255.255.0
         ipv4 host-static 10.0.1.1 0000.0a00.0101
         mpls enable
         router isis4 1 enable
         router isis4 1 circuit level1
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
         router isis4 1 enable
         router isis4 1 circuit level1
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
         router isis4 1 circuit level1  
         router isis4 1 segrout index 1
         router isis4 1 segrout node                    
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
         router isis4 1 circuit level1
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
        label   vrf   iface      hop         label       targets  bytes
        99818   v1:4  ethernet0  10.0.1.254  unlabelled           0     
        114632  v1:4  ethernet0  10.0.1.254  3                    0     
        176497  v1:4  ethernet0  10.0.1.254  unlabelled           0     
        591064  v1:4  ethernet0  10.0.1.254  972512               0     
        662375  null  null       null        unlabelled           0     
        662376  v1:4  null       null        unlabelled  local    924600
        662377  v1:4  ethernet0  10.0.1.254  972512               0     
        662378  v1:4  ethernet0  10.0.1.254  972513               0     
        662379  null  null       null        unlabelled           0     
        662380  null  null       null        unlabelled           0     
        662381  null  null       null        unlabelled           0     
        662382  null  null       null        unlabelled           0     
        662383  null  null       null        unlabelled           0     
        662384  null  null       null        unlabelled           0     
        827849  v1:4  ethernet0  10.0.1.254  unlabelled           0     
        839378  v1:6  null       null        unlabelled  local    0     
        871196  v1:4  null       null        unlabelled  local    0     
        879577  v1:4  ethernet0  10.0.1.254  972513               0     

        cpe1#sh ipv4 route v1 10.254.254.254 | i seg
        segment routing index = 2                   
        segment routing old base = 972510           
        segment routing base = 972510               
        segment routing size = 0                    

        cpe1#sh ipv4 route v1 10.2.2.2 | i seg
        segment routing index = 3             
        segment routing old base = 930979     
        segment routing base = 972510         
        segment routing size = 0                                                                  

 * `cpe2`

        cpe2#show mpls forwarding                                       
        label   vrf   iface      hop         label       targets  bytes
        247045  v1:6  null       null        unlabelled  local    0     
        284560  v1:4  ethernet0  10.0.2.254  unlabelled           0     
        378709  v1:4  ethernet0  10.0.2.254  972511               0     
        387251  v1:4  ethernet0  10.0.2.254  3                    0     
        457138  v1:4  ethernet0  10.0.2.254  972512               0     
        552642  v1:4  ethernet0  10.0.2.254  unlabelled           0     
        649628  v1:4  ethernet0  10.0.2.254  unlabelled           0     
        758959  v1:4  null       null        unlabelled  local    0     
        930979  null  null       null        unlabelled           0     
        930980  v1:4  ethernet0  10.0.2.254  972511               0     
        930981  v1:4  ethernet0  10.0.2.254  972512               0     
        930982  v1:4  null       null        unlabelled  local    933708
        930983  null  null       null        unlabelled           0     
        930984  null  null       null        unlabelled           0     
        930985  null  null       null        unlabelled           0     
        930986  null  null       null        unlabelled           0     
        930987  null  null       null        unlabelled           0     
        930988  null  null       null        unlabelled           0     

        cpe2#sh ipv4 route v1 10.254.254.254 | i seg
        segment routing index = 2                   
        segment routing old base = 972510           
        segment routing base = 972510               
        segment routing size = 0          

        cpe2#sh ipv4 route v1 10.1.1.1    
        segment routing index = 1         
        segment routing old base = 662375
        segment routing base = 972510     
        segment routing size = 0          

 * `core1`

        core1#show mpls forwarding                                   
        label   vrf   iface      hop       label       targets  bytes
        45097   v1:4  ethernet1  10.0.2.2  930982               0    
        262855  v1:4  ethernet0  10.0.1.1  unlabelled           0    
        315171  v1:4  null       null      unlabelled  local    0    
        446106  v1:6  null       null      unlabelled  local    0    
        555166  v1:4  ethernet1  10.0.2.2  3                    0    
        568587  v1:4  ethernet1  10.0.2.2  unlabelled           0    
        769932  v1:4  ethernet0  10.0.1.1  662376               0    
        823341  v1:4  ethernet0  10.0.1.1  3                    0    
        972510  null  null       null      unlabelled           0    
        972511  v1:4  ethernet0  10.0.1.1  662376               0    
        972512  v1:4  null       null      unlabelled  local    3680
        972513  v1:4  ethernet1  10.0.2.2  930982               0    
        972514  null  null       null      unlabelled           0    
        972515  null  null       null      unlabelled           0    
        972516  null  null       null      unlabelled           0    
        972517  null  null       null      unlabelled           0    
        972518  null  null       null      unlabelled           0    
        972519  null  null       null      unlabelled           0   

        core1#sh ipv4 route v1 10.1.1.1 | i seg
        segment routing index = 1              
        segment routing old base = 662375      
        segment routing base = 662375          
        segment routing size = 0               

        core1#sh ipv4 route v1 10.2.2.2 | i seg
        segment routing index = 3              
        segment routing old base = 930979      
        segment routing base = 930979          
        segment routing size = 0               

* But forwarding does not occur even if `core1` control plane `isis-sr` converged.
```
cpe1#ping 10.2.2.2 /vrf v1 /interface lo0                                                                                         
pinging 10.2.2.2, src=10.1.1.1, cnt=5, len=64, tim=1000, ttl=255, tos=0, sweep=false
.....
result=0%, recv/sent/lost=0/5/5, rtt min/avg/max/total=10000/0/0/5009
cpe1#                                                                       
```

No worry... This is again an expected behaviour !  
If you notice just right after ISIS convergence, `ping` tests were successful. After SR activation and convergence, connectivity is again "broken" as it was the case for LDP. The reason is that now the traffic is MPLS encapsulated and is not recognized by `p4-core1`.

However, there is one big difference between LDP. In SR case, MPLS encapsulation include only the NODE SID. (i.e `10.1.1.1`, `10.254.254.254`,`10.2.2.2`) While LDP was allocation for each IPv4 FEC.

Let's write some P4 rules based on `core1` MPLS forwarding and SR information:

    # Entry corresponding to Label imposition from core1
    # at P4 level (swap against itself) for FEC to cpe1
    # This is a special case as FreeRTR is performing label imposition at control plane level
    # P4 Object: tbl_mpls_fib
    # Table key: 662376
    # Action id: act_mpls_swap_set_nexthop
    # Action params: {662376 1}
    # Trigger: when core1 FreeRTR ISIS-SR has converged
    table_add tbl_mpls_fib act_mpls_swap_set_nexthop 662376 => 662376 1

    # Entry corresponding to Label imposition from core1
    # at P4 level (swap against itself) for FEC to core1 .
    # This is a special case as FreeRTR is performing label imposition at control plane level
    # P4 Object: tbl_mpls_fib
    # Table key: 972512
    # Action id: act_mpls_swap_set_nexthop
    # Action params: {972512 255}
    # Trigger: when core1 FreeRTR ISIS-SR has converged    
    table_add tbl_mpls_fib act_mpls_swap_set_nexthop 972512 => 972512 255

    # Entry corresponding to Label imposition from core1
    # at P4 level (swap against itself) for FEC to cpe2 .
    # This is a special case as FreeRTR is performing label imposition at control plane level
    # P4 Object: tbl_mpls_fib
    # Table key: 930982
    # Action id: act_mpls_swap_set_nexthop
    # Action params: {930982 2}
    # Trigger: when core1 FreeRTR ISIS-SR has converged        
    table_add tbl_mpls_fib act_mpls_swap_set_nexthop 930982 => 930982 2

    # Entry corresponding to Label swap operation from core1
    # at P4 level (label swap) for FEC to cpe1.
    # This is a the case as FreeRTR is performing label swap at the p4-core1 level
    # P4 Object: tbl_mpls_fib
    # Table key: 972513
    # Action id: act_mpls_swap_set_nexthop
    # Action params: {930982 2}
    # Trigger: when core1 FreeRTR ISIS-SR has converged             
    table_add tbl_mpls_fib act_mpls_swap_set_nexthop 972513 => 930982 2

    # Entry corresponding to Label swap operation from core1
    # at P4 level (label swap) for FEC to cpe2.
    # This is a the case as FreeRTR is performing label swap at the p4-core1 level
    # P4 Object: tbl_mpls_fib
    # Table key: 972511
    # Action id: act_mpls_swap_set_nexthop
    # Action params: {662376 1}
    # Trigger: when core1 FreeRTR ISIS-SR has converged                 
    table_add tbl_mpls_fib act_mpls_swap_set_nexthop 972511 => 662376 1

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

* IMPORTANT note:
`ping` is working for `lo0` and `lo1` but if you `tcpcump` these ping you'll notice that in one case `lo0` MPLS forwarding driven by SR occur. While for `lo1` basic IPv4 forwarding is occuring.                  

# Key take-away
* This labs put the focus on P4 code snippets necessary to enable ISIS-SR operation with FreeRTR.
* At P4 level, the code is stricly identical to [LDP lab](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0005-defauld-ldp-operation/p4src).
* FreeRTR is not performing PHP so decapsulation action is never triggered
* There is a particular case where `core1` is encapsulating packets at the control plane level. This correspond to a swap at P4 level using the same label as ingress / egress label. (A better solution would be to match is the ingress/egress port is a control plane port just send to the corresponding CPU port without any modification of the packets)
* Again, MPLS forwarding is effective only for the NODE SID(s).
* Last but not least, this example works as `arp` mapping was statically applied at FreeRTR level on `cpe1` and `core1` with the `ipv4 host-static <ipv4-address> <hw-address>` command.

# Follow-ups
* At this stage, we have a router that has core MPLS P functions.
   * Now P function is ensured by ISIS-SR (no more LDP)
   * However, essential features are missing. Features like router ACL or basic Control Plane protection will be the object of subsequent Labs.
* Considering the previous section, this `arp` mapping must be dynamic especially in production environment.   
   * `L2 learning` will be the object of a subsequent Lab.
