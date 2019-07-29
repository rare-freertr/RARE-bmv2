/*
* P4 language version: P4_16 
*/

#include <core.p4>
#include <v1model.p4>
#include <include/ethertype.p4>
#include <include/ip-protocol.p4>
#include <include/ethernet.p4>
#include <include/ipv4.p4>
#include <include/ipv6.p4>
#include <include/p4-table.p4>
#include <include/types.p4>
#include <include/headers.p4>
#include <include/validate_ipv6.p4>
#include <include/l3_ipv6.p4>

/*
* User-defined metadata
*/
struct metadata {
}

/*
* V1Model PARSER
*/
parser prs_main(packet_in packet,
out headers hdr,
inout metadata meta,
inout standard_metadata_t standard_metadata) {

    state start {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.ethertype) {
            ETHERTYPE_IPV6: prs_ipv6;
            // Default rejects all other ethertypes
        }
    }

    state prs_ipv6 {
        packet.extract(hdr.ipv6);
        transition accept;
    }

}

/*
* V1Model CHECKSUM VERIFICATION 
*/
control ctl_verify_checksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

/*
* V1Model INGRESS
*/
control ctl_ingress(inout headers hdr,
inout metadata meta,
inout standard_metadata_t standard_metadata) {

    ctl_validate_ipv6() validate;
    ctl_l3_ipv6() l3;

    apply {
        if (hdr.ipv6.isValid()) {
            validate.apply(hdr, standard_metadata);
            l3.apply(hdr, standard_metadata);
        }
    }
}

/*
* V1Model EGRESS
*/

control ctl_egress(inout headers hdr,
inout metadata meta,
inout standard_metadata_t standard_metadata) {
    apply {
    }
}

/*
* V1Model CHECKSUM COMPUTATION
*/
control ctl_compute_checksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

/*
* V1Model DEPARSER
*/
control ctl_deprs(packet_out packet, in headers hdr) {
    apply {
        /* parsed headers that have been modified
        * in ctl_ingress and ctl_ingress
        * have to be added again into the packet.
        * for emission in the wire
        */
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv6);

    }
}

/*
* V1Model P4 Switch define in v1model.p4
*/
V1Switch(
prs_main(),
ctl_verify_checksum(),
ctl_ingress(),
ctl_egress(),
ctl_compute_checksum(),
ctl_deprs()
) main;
