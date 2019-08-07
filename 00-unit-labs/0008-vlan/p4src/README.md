mc_node_create 100 2 3
mirroring_add_mc 100 100

table_add ctl_ingress.tbl_vlan ctl_ingress.act_vlan_trunk_hit 100 => 100
