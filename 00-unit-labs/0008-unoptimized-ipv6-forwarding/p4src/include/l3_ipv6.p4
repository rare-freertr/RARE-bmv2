#ifndef _L3_IPV6_P4_
#define _L3_IPV6_P4_

#include <v1model.p4>
#include <include/p4-table.p4>
#include <include/headers.p4>

control ctl_l3_ipv6(inout headers hdr,
inout standard_metadata_t standard_metadata) {

    /* Discard via V1Model mark_to_drop(standard_metadata) */
    action act_ipv6_fib_discard() {
        mark_to_drop(standard_metadata);
    }

    /* Perform L3 forwarding. Conceptually, we need to distinguish the
       cases when rewriting the Ethernet header is necessary and when
       it is not.

       If the destination is an address that belongs to the router
       itself, a rewrite is not necessary, because the packet has
       already reached its destination device.  The list of these
       "local" addresses is stored in the exact-match table
       tbl_ipv6_fib_host.

       If the address belongs to a network that is directly attached
       to the router, the packet can be sent to the final destination.

       If the destination is not directly attached but there is a
       prefix covering it in the routing table, the packet is
       forwarded to the next-hop router.

       In both of these cases, the router must rewrite the Ethernet
       header with the proper source and destination MAC addresses.

       The list of connected networks and routed prefixes is stored in
       the lpm table tbl_ipv6_fib_lpm.  For a routed prefix, the table
       stores the MAC addresses and egress port to reach the next-hop
       router.  It is assumed that these parameters are obtained by
       the control-plane when the FIB is programmed.

       For a connected network, the router cannot generate the
       destination MAC addresses for all possible destinations
       beforehand. Instead, a match for a connected network would
       trigger an address resolution request to the control-plane.

       Once the control-plane has completed address resolution, it
       adds a an entry to the exact-match table where the local
       addresses are stored, but the entry for a connected destination
       contains the same information as the lpm table. */

    /* Packets for local addresses are sent to the CPU.  In the final
       architecture, there will be a single designated port and this
       function won't need an argument.  In the current lab setup,
       each local port is connected via a separate port to the
       control-plane. */
    action act_ipv6_fib_local(egress_spec_t egress_cpu_port) {
        standard_metadata.egress_spec = egress_cpu_port;
    }

    action act_ipv6_fib_forward(mac_addr_t src_mac_addr, mac_addr_t dst_mac_addr,
    egress_spec_t egress_port) {
        
        /* Source is the MAC address of the egress port, destination
           is the MAC address of the next-hop or the final destination
           in case of a directly attached network. */
        hdr.ethernet.src_mac_addr = src_mac_addr;
        hdr.ethernet.dst_mac_addr = dst_mac_addr;
        
        /* Underflow causes no harm, because packets with a hop
           limit of 0 have already been marked for drop */
        hdr.ipv6.hop_limit = hdr.ipv6.hop_limit -1;
        
        standard_metadata.egress_spec = egress_port;
    }

    action act_ipv6_fib_glean() {
        /* An address resolution request would be generate at this
           point. For now, we have no choice but to drop the
           packet. */
        mark_to_drop(standard_metadata);
    }
    
    table tbl_ipv6_fib_host {
        key = {
            hdr.ipv6.dst_ipv6_addr: exact;
        }
        actions = {
            act_ipv6_fib_local;
            act_ipv6_fib_forward;
            NoAction;
        }
        size = IPV6_HOST_TABLE_SIZE;
        const default_action = NoAction;
    }
    
    table tbl_ipv6_fib_lpm {
        key = {
            hdr.ipv6.dst_ipv6_addr: lpm;
        }
        actions = {
            act_ipv6_fib_forward;
            act_ipv6_fib_glean;
            act_ipv6_fib_discard;
        }
        size = IPV6_LPM_TABLE_SIZE;
        const default_action = act_ipv6_fib_discard();
    }

    apply {
        if (!tbl_ipv6_fib_host.apply().hit) {
            tbl_ipv6_fib_lpm.apply();
        }
    }
}          

#endif // _L3_IPV6_P4_
