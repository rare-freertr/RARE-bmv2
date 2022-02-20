/*
 * Copyright 2019-present GT RARE project
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

#ifndef _IG_CTL_PBR_P4_
#define _IG_CTL_PBR_P4_

control IngressControlPBR(inout headers hdr,
                          inout ingress_metadata_t ig_md,
                          inout standard_metadata_t ig_intr_md) {

    direct_counter(CounterType.packets_and_bytes) stats4;
    direct_counter(CounterType.packets_and_bytes) stats6;

    action act_normal() {
    }

    action act_setvrf(switch_vrf_t vrf_id) {
        ig_md.vrf = vrf_id;
    }

    action act_sethop(switch_vrf_t vrf_id, NextHopId_t nexthop_id) {
        ig_md.vrf = vrf_id;
        ig_md.nexthop_id = nexthop_id;
        ig_md.ipv4_valid = 0;
        ig_md.ipv6_valid = 0;
    }

    action act_setlabel(switch_vrf_t vrf_id, NextHopId_t nexthop_id, label_t label_val) {
        ig_md.ethertype = ETHERTYPE_MPLS_UCAST;
        ig_md.mpls0_remove = 0;
        hdr.mpls0.setValid();
        hdr.mpls0.label = label_val;
        hdr.mpls0.ttl = 255;
        hdr.mpls0.bos = 1;
        ig_md.vrf = vrf_id;
        ig_md.nexthop_id = nexthop_id;
        ig_md.ipv4_valid = 0;
        ig_md.ipv6_valid = 0;
    }



    table tbl_ipv4_pbr {
        key = {
ig_md.vrf:
            exact;
hdr.ipv4.protocol:
            ternary;
hdr.ipv4.src_addr:
            ternary;
hdr.ipv4.dst_addr:
            ternary;
ig_md.layer4_srcprt:
            ternary;
ig_md.layer4_dstprt:
            ternary;
hdr.ipv4.diffserv:
            ternary;
hdr.ipv4.identification:
            ternary;
ig_md.sec_grp_id:
            ternary;
        }
        actions = {
            act_normal;
            act_setvrf;
            act_sethop;
            act_setlabel;
            @defaultonly NoAction;
        }
        size = IPV4_PBRACL_TABLE_SIZE;
        const default_action = NoAction();
        counters = stats4;
    }

    table tbl_ipv6_pbr {
        key = {
ig_md.vrf:
            exact;
hdr.ipv6.next_hdr:
            ternary;
hdr.ipv6.src_addr:
            ternary;
hdr.ipv6.dst_addr:
            ternary;
ig_md.layer4_srcprt:
            ternary;
ig_md.layer4_dstprt:
            ternary;
hdr.ipv6.traffic_class:
            ternary;
hdr.ipv6.flow_label:
            ternary;
ig_md.sec_grp_id:
            ternary;
        }
        actions = {
            act_normal;
            act_setvrf;
            act_sethop;
            act_setlabel;
            @defaultonly NoAction;
        }
        size = IPV6_PBRACL_TABLE_SIZE;
        const default_action = NoAction();
        counters = stats6;
    }

    apply {
        if (ig_md.ipv4_valid==1)  {
            tbl_ipv4_pbr.apply();
        }
        if (ig_md.ipv6_valid==1)  {
            tbl_ipv6_pbr.apply();
        }
    }
}

#endif // _IG_CTL_PBR_P4_

