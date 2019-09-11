mc_node_create 100 2 3
# OUT: Creating node with rid 100 , port map 1100 and lag map
# OUT: node was created with handle 0
# This handle is used in the association

mc_mgrp_create 100
# OUT: Creating multicast group 100
mc_node_associate 100 0
# OUT: Associating node 1 to multicast group 100

mirroring_add_mc 100 100


# RuntimeCmd: mc_dump
# ==========
# MC ENTRIES
# **********
# mgrp(100)
#  -> (L1h=0, rid=100) -> (ports=[2, 3], lags=[])
# ==========
# LAGS
# ==========


# GARBAGE, PROBABLY REMOVE mirroring_add_mc 100 100

## GARBAGE, PROBABLY PURGE table_add ctl_ingress.tbl_vlan ctl_ingress.act_vlan_trunk_hit 100 => 100

## act_vlan_hit(port, trunk, vid) => mc group
# Tagged incomming traffic
table_add ctl_ingress.tbl_vlan_match ctl_ingress.act_vlan_hit 1 1 100 => 100
# Untagged incomming traffic
table_add ctl_ingress.tbl_vlan_match ctl_ingress.act_vlan_hit 1 0 0 => 100
# How to output the traffic on each port.
# Should be the same vlan for the group if no vlan translation is desired
table_add ctl_egress.tbl_vlan_out ctl_egress.egress_push_tag 100 2 => 102
table_add ctl_egress.tbl_vlan_out ctl_egress.egress_push_tag 100 3 => 103
