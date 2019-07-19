/*
* P4 language version: P4_16 
*/

/*
* include P4 core library 
*/
#include <core.p4>

/* 
* include P4 v1model library implemented by simple_switch 
*/
#include <v1model.p4>

/*
* include Ethertype mapping 
*/
#include <include/ethertype.p4>

/* 
* include IP protocol mapping 
*/
#include <include/ip-protocol.p4>

/* 
* include Ethernet types and protocol headers
*/
#include <include/ethernet.p4>

/* 
* include IPv4 types and protocol headers
*/
#include <include/ipv4.p4>

/* 
* include IPv6 types and protocol headers
*/
#include <include/ipv6.p4>

/* 
* include P4 table size declaration 
*/
#include <include/p4-table.p4>

/*
* egress_spec port encoded using 9 bits
*/ 
typedef bit<9>  egress_spec_t;

/*
* empty struct but still need to be declared as it is used in parser
*/
struct metadata {
}

/*
* Our P4 program header structure 
*/
struct headers {
    ethernet_t   ethernet;
    ipv6_t       ipv6;
}

/* Must come after declarations above */
#include <include/validate_ipv6.p4>
#include <include/l3_ipv6.p4>

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
