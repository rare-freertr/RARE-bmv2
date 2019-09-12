# LAB Topology
Since this lab is focused in multicasting and replication of packets as needed by VLAN services, the topology is changed and corresponds of that of OOOO-topology-VLAN. This topology produces 4 hosts connected to ports 1,2,3,4 of a bmv2 p4 switch.

# LAB Title
** Simple-VLAN **

# LAB Objective
The objective of this lab is to showcase how to use the clone3() p4 command to be able to replicate packets.

In this case and just for the sake of showing the versatlity, vpls alike behaviour is shown. If the switch behaves as a simple VLAN switch or does vlan translation among others is just a matter on how the tables are populated.

The scenario prepared has each host configured with a different vlan and mode.
- Host1 is configured as access vlan 100 connected to switch port 1
- Host2 is configured as trunk vlan 102 connected to switch port 2
- Host3 is configured as trunk vlan 103 connected to switch port 3
- Host4 is configured as trunk vlan 104 connected to switch port 4

# Lab operation
Launch the 000-topology-VLAN topology using **make**.
Compile vlan-operation.p4 by means of makefile.
Launch the CLI with *simple_switch_CLI --thrift-port 9090 < switch-commands.txt*. This will automatically populate the tables of the switch.

Connectivity tests can be performed by issuing commands:
* ip netns exec host1 ping 192.168.69.2 -c 1
* ip netns exec host1 ping 192.168.69.3 -c 1
* ip netns exec host1 ping 192.168.69.4 -c 1

Meanwhile, the capture of the packets live can be obtained by issuing commands:
* ip netns exec host1 tcpdump -lei host1-eth0
* ip netns exec host2 tcpdump -lei host2-eth0
* ip netns exec host3 tcpdump -lei host3-eth0
* ip netns exec host4 tcpdump -lei host4-eth0

# Control plane population sample
Here we try to explain each of the commands issued to the switch through the simple_switch_CLI

```
vagrant@ubuntu1604:~/RARE/00-unit-labs/0008-vlan/p4src$ simple_switch_CLI --thrift-port 9090 < switch-commands.txt
Obtaining JSON from switch...
Done
Control utility for runtime P4 table manipulation
RuntimeCmd: mc_node_create 100 1 2 3 4
Creating node with rid 100 , port map 11110 and lag map
node was created with handle 0
```
The first command creates the multicast node with the ID 100 (it has been selected it randomly for demo purposes) and assigns ports 1,2,3 and 4 to it.
It is **important** to observe that the **handle ID** differs from that of the node.

```
RuntimeCmd: mc_mgrp_create 100
Creating multicast group 100
```
Create multicast group 100 (it could differ from that of the node as we'll see shortly).

```
RuntimeCmd: mc_node_associate 100 0
Associating node 0 to multicast group 100
```
Associate the multicast node (using the **handle ID**) with the group.

```
RuntimeCmd: mirroring_add_mc 100 100
```

Now the mirroring ID is added to the multicast group.

From this point the the multicast config can be dumped:
```
RuntimeCmd: mirroring_add_mc 100 100
# RuntimeCmd: mc_dump
# ==========
# MC ENTRIES
# **********
# mgrp(100)
#   -> (L1h=0, rid=100) -> (ports=[1, 2, 3, 4], lags=[])
# ==========
# LAGS
# ==========
```

Now we populate the ingress table. So how the packets leaving each of the hosts are going to be accepted and to which multicast group they are going to be associated. In our case we have just one.
- act_vlan_hit(port, trunk, vid) => mc_group

Where port is the port of the switch to which the host is attached. Trunk is 0 if Access and 1 if trunk mode is used, vid is the vid and finally mc_group is the multicast group used for replication.


```
RuntimeCmd: table_add ctl_ingress.tbl_vlan_match ctl_ingress.act_vlan_hit 1 0 0 => 100
Adding entry to exact match table ctl_ingress.tbl_vlan_match
match key:           EXACT-00:01        EXACT-00        EXACT-00:00
action:              ctl_ingress.act_vlan_hit
runtime data:        00:00:00:64
Entry has been added with handle 0
RuntimeCmd: table_add ctl_ingress.tbl_vlan_match ctl_ingress.act_vlan_hit 2 1 102 => 100
Adding entry to exact match table ctl_ingress.tbl_vlan_match
match key:           EXACT-00:02        EXACT-01        EXACT-00:66
action:              ctl_ingress.act_vlan_hit
runtime data:        00:00:00:64
Entry has been added with handle 1
RuntimeCmd: table_add ctl_ingress.tbl_vlan_match ctl_ingress.act_vlan_hit 3 1 103 => 100
Adding entry to exact match table ctl_ingress.tbl_vlan_match
match key:           EXACT-00:03        EXACT-01        EXACT-00:67
action:              ctl_ingress.act_vlan_hit
runtime data:        00:00:00:64
Entry has been added with handle 2
RuntimeCmd: table_add ctl_ingress.tbl_vlan_match ctl_ingress.act_vlan_hit 4 1 104 => 100
Adding entry to exact match table ctl_ingress.tbl_vlan_match
match key:           EXACT-00:04        EXACT-01        EXACT-00:68
action:              ctl_ingress.act_vlan_hit
runtime data:        00:00:00:64
Entry has been added with handle 3
```
Anything not in these possibilities is discarded.

Now egress table is populated, basically inverted to that of the Ingress.
```
RuntimeCmd: table_add ctl_egress.tbl_vlan_out ctl_egress.egress_no_tag 100 1 =>
Adding entry to exact match table ctl_egress.tbl_vlan_out
match key:           EXACT-00:00:00:64  EXACT-00:01
action:              ctl_egress.egress_no_tag
runtime data:
Entry has been added with handle 0
RuntimeCmd: table_add ctl_egress.tbl_vlan_out ctl_egress.egress_push_tag 100 2 => 102
Adding entry to exact match table ctl_egress.tbl_vlan_out
match key:           EXACT-00:00:00:64  EXACT-00:02
action:              ctl_egress.egress_push_tag
runtime data:        00:66
Entry has been added with handle 1
RuntimeCmd: table_add ctl_egress.tbl_vlan_out ctl_egress.egress_push_tag 100 3 => 103
Adding entry to exact match table ctl_egress.tbl_vlan_out
match key:           EXACT-00:00:00:64  EXACT-00:03
action:              ctl_egress.egress_push_tag
runtime data:        00:67
Entry has been added with handle 2
RuntimeCmd: table_add ctl_egress.tbl_vlan_out ctl_egress.egress_push_tag 100 4 => 104
Adding entry to exact match table ctl_egress.tbl_vlan_out
match key:           EXACT-00:00:00:64  EXACT-00:04
action:              ctl_egress.egress_push_tag
runtime data:        00:68
Entry has been added with handle 3
RuntimeCmd:

```
