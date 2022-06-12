/*
 * Copyright 2019-present GEANT RARE project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed On an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef _EG_CTL_VLAN_OUT_P4_
#define _EG_CTL_VLAN_OUT_P4_

control EgressControlVlanOut(inout headers hdr,
                             inout ingress_metadata_t eg_md,
                             inout standard_metadata_t eg_intr_md) {

    counter((MAX_PORT+1), CounterType.packets_and_bytes) stats;

    action act_set_vlan_port(SubIntId_t port, vlan_id_t vlan) {
        eg_md.outport_id = port;
        hdr.vlan.setValid();
        hdr.vlan.ethertype = eg_md.ethertype;
        hdr.ethernet.ethertype = ETHERTYPE_VLAN;
        hdr.vlan.vid = vlan;
    }

    action act_set_port() {
        eg_md.outport_id = eg_md.target_id;
        hdr.ethernet.ethertype = eg_md.ethertype;
    }

    table tbl_vlan_out {
        key = {
eg_md.target_id:
            exact;
        }
        actions = {
            act_set_port;
            act_set_vlan_port;
        }
        size = VLAN_TABLE_SIZE;
        default_action = act_set_port();
    }

    apply {
        stats.count((bit<32>)eg_md.target_id);
        tbl_vlan_out.apply();
    }
}

#endif // _EG_CTL_VLAN_OUT_P4_

