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
* include P4 table size declaration
*/
#include <include/p4-table.p4>

/*
* egress_spec port encoded using 9 bits
*/
typedef bit<9>  egress_spec_t;

/*
* HW MAC address encoded using 48 bits
*/
typedef bit<48> mac_addr_t;

/*
* Ethernet header: as a header type, order matters
*/
header ethernet_t {
    mac_addr_t dst_mac_addr;
    mac_addr_t src_mac_addr;
    bit<16>   ethertype;
}

/*
* IEEE 802.1Q - VLAN-tagged frame: as a header type, order matters
*/
header vlan_t {
    bit<48> dstAddr;        // Destination MAC Address
    bit<48> srcAddr;        // Source MAC Address
    bit<16> tpid;           // Tag Protocol Identifier (TPID)
    bit<3>  pcp;            // Priority Code Point (PCP)
    bit<1>  dei;            // Drop Eligible Indicator (DEI)
    bit<12> vid;            // VLAN Identifier (VID)
    bit<16> etherType;      // EtherType
}

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
    vlan_t       vlan;
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
            ETHERTYPE_VLAN: prs_vlan;
            default: accept;
        }
    }

    state prs_vlan {
        packet.extract(hdr.vlan);
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
        packet.emit(hdr.vlan);
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
