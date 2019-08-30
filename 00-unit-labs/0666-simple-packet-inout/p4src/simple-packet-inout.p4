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
#include "include/ethertype.p4"

/* 
 * include IP protocol mapping 
 */
#include "include/ip-protocol.p4"

/* 
 * include P4 table size declaration 
 */
#include "include/p4-table.p4"

/* 
 * include P4 switch port information 
 */
// #include "p4-switch-port.p4"

/*
 * egress_spec port encoded using 9 bits
 */ 
typedef bit<9>  egress_spec_t;

/*
 * HW MAC address encoded using 48 bits
 */
typedef bit<48> mac_addr_t;

/*
 * IPv4 address encoded using 32 bits
 */
typedef bit<32> ipv4_addr_t;

/*
 * Nexthop using 16 bits
 */
typedef bit<9> nexthop_id_t;

/*
 * MPLS label using 20 bits
 */
typedef bit<20> label_t;


/*
 * IPv4 address encoded using 32 bits
 */
typedef bit<32> stack_index_t;

typedef bit<9> port_t;
const port_t CPU_PORT = 64;

header packet_in_header_t {
    port_t ingress_port;
    bit<7> _padding;
}

header packet_out_header_t {
    port_t egress_port;
    bit<7> _padding;
}


/*
 * Ethernet header: as a header type, order matters
 */
header ethernet_t {
   mac_addr_t dst_mac_addr;
   mac_addr_t src_mac_addr;
   bit<16>   ethertype;
}

/*
 * LLC header: as a header type, order matters
 */
header llc_header_t {
   bit<8> dsap;
   bit<8> ssap;
   bit<8> control_;
}

/*
 * MPLS header: as a header type, order matters
 */
header mpls_t {
   label_t label;
   bit<3>  exp;
   bit<1>  bos;
   bit<8>  ttl;
}

/*
 * ICMP header: as a header type, order matters
 */
header icmp_t {
    bit<16> type_code;
    bit<16> hdr_checksum;
}

/*
 * IPv4 header: as a header type, order matters
 */
header ipv4_t {
   bit<4>    version;
   bit<4>    ihl;
   bit<8>    diffserv;
   bit<16>   total_len;
   bit<16>   identification;
   bit<3>    flags;
   bit<13>   frag_offset;
   bit<8>    ttl;
   bit<8>    protocol;
   bit<16>   hdr_checksum;
   ipv4_addr_t src_addr;
   ipv4_addr_t dst_addr;
}

/*
 * IPv6 header: as a header type, order matters
 */
header ipv6_t {
    bit<4>   version;
    bit<8>   traffic_class;
    bit<20>  flow_label;
    bit<16>  payload_len;
    bit<8>   next_hdr;
    bit<8>   hop_limit;
    bit<128> src_addr;
    bit<128> dst_addr;
}


header tcp_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<32> seq_no;
    bit<32> ack_no;
    bit<4>  data_offset;
    bit<4>  res;
    bit<8>  flags;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgent_ptr;
}

header udp_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<16> length_;
    bit<16> checksum;
}


struct ingress_intrinsic_metadata_t {
    bit<1>  resubmit_flag;
    bit<48> ingress_global_timestamp;
    bit<16> mcast_grp;
    bit<1>  deflection_flag;
    bit<1>  deflect_on_drop;
    bit<2>  enq_congest_stat;
    bit<2>  deq_congest_stat;
    bit<13> mcast_hash;
    bit<16> egress_rid;
    bit<32> lf_field_list;
    bit<3>  priority;
    bit<3>  ingress_cos;
    bit<2>  packet_color;
    bit<5>  qid;
}

/*
 * L3 metadata type  
 */
struct l3_metadata_t {
    bit<2>  lkp_ip_type;
    bit<4>  lkp_ip_version;
    bit<8>  lkp_ip_proto;
    bit<8>  lkp_dscp;
    bit<8>  lkp_ip_ttl;
    bit<16> lkp_l4_sport;
    bit<16> lkp_l4_dport;
    bit<16> lkp_outer_l4_sport;
    bit<16> lkp_outer_l4_dport;
    label_t vrf;
    stack_index_t stack_cur_idx;
    bit<10> rmac_group;
    bit<1>  rmac_hit;
    bit<2>  urpf_mode;
    bit<1>  urpf_hit;
    bit<1>  urpf_check_fail;
    bit<16> urpf_bd_group;
    bit<1>  fib_hit;
    bit<16> fib_nexthop;
    bit<2>  fib_nexthop_type;
    bit<16> same_bd_check;
    bit<16> nexthop_index;
    bit<1>  routed;
    bit<1>  outer_routed;
    bit<8>  mtu_index;
    bit<1>  l3_copy;
    bit<16> l3_mtu_check;
    bit<16> egress_l4_sport;
    bit<16> egress_l4_dport;
}

/*
 * IPv4 metadata type
 */
struct ipv4_metadata_t {
    ipv4_addr_t lkp_ipv4_sa;
    ipv4_addr_t lkp_ipv4_da;
    bit<1>  ipv4_unicast_enabled;
    bit<2>  ipv4_urpf_mode;
}

/*
 * IPv6 metadata type
 */
struct ipv6_metadata_t {
    bit<128> lkp_ipv6_sa;
    bit<128> lkp_ipv6_da;
    bit<1>   ipv6_unicast_enabled;
    bit<1>   ipv6_src_is_link_local;
    bit<2>   ipv6_urpf_mode;
}

struct tunnel_metadata_t {
    bit<5>  ingress_tunnel_type;
    bit<24> tunnel_vni;
    bit<1>  mpls_enabled;
    bit<20> mpls_label;
    bit<3>  mpls_exp;
    bit<8>  mpls_ttl;
    bit<5>  egress_tunnel_type;
    bit<14> tunnel_index;
    bit<9>  tunnel_src_index;
    bit<9>  tunnel_smac_index;
    bit<14> tunnel_dst_index;
    bit<14> tunnel_dmac_index;
    bit<24> vnid;
    bit<1>  tunnel_terminate;
    bit<1>  tunnel_if_check;
    bit<4>  egress_header_count;
    bit<8>  inner_ip_proto;
    bit<1>  skip_encap_inner;
}

/*
 * metadata type  
 */
struct metadata_t {
   nexthop_id_t                 nexthop_id;
   ingress_intrinsic_metadata_t intrinsic_metadata;
   l3_metadata_t                l3_metadata;
   ipv4_metadata_t              ipv4_metadata;
   ipv6_metadata_t              ipv6_metadata;
   tunnel_metadata_t            tunnel_metadata;
}

/*
 * Our P4 program header structure 
 */
struct headers {
   /*icmp_t       inner_icmp;
   ipv4_t       inner_ipv4;
   ipv6_t       inner_ipv6;
   tcp_t        inner_tcp;
   udp_t        inner_udp;*/
   packet_out_header_t packet_out;
   packet_in_header_t packet_in;
   ethernet_t   ethernet;
   mpls_t[3]    mpls;
   ipv4_t       ipv4;
   ipv6_t       ipv6;
   llc_header_t llc_header;
   tcp_t        tcp;
   udp_t        udp;
}

/*
 * V1Model PARSER
 */
parser prs_main(packet_in packet,
                out headers hdr,
                inout metadata_t md,
                inout standard_metadata_t std_md) {

   state start {
      transition select(std_md.ingress_port) {
      CPU_PORT: prs_packet_out;
      default: prs_ethernet;
      }
   }

   state prs_packet_out {
      packet.extract(hdr.packet_out);
      transition prs_ethernet;
   }

   state prs_ethernet {
      packet.extract(hdr.ethernet);
      md.intrinsic_metadata.priority = 0;
      md.l3_metadata.vrf = 0;
      transition select(hdr.ethernet.ethertype) {
         default: accept;
      }
   }

}

/*
 * V1Model CHECKSUM VERIFICATION 
 */
control ctl_verify_checksum(inout headers hdr, inout metadata_t metadata) {
    apply {
  }
}


/*
 * V1Model INGRESS
 */
control ctl_ingress(inout headers hdr,
                  inout metadata_t md,
                  inout standard_metadata_t std_md) {

   apply {
      if (std_md.ingress_port == CPU_PORT) {
         // Packet received from CPU_PORT, this is a packet-out sent by the
         // controller. Skip table processing, set the egress port as
         // requested by the controller (packet_out header) and remove the
         // packet_out header.
         //md.nexthop_id = hdr.packet_out.egress_port;
         std_md.egress_spec = hdr.packet_out.egress_port;
         hdr.packet_out.setInvalid();
      } else {
         // Packet received from data plane port.
         std_md.egress_spec = CPU_PORT; 
         //md.nexthop_id = CPU_PORT;
         // Packets sent to the controller needs to be prepended with the
         // packet-in header. By setting it valid we make sure it will be
         // deparsed on the wire (see c_deparser).
         hdr.packet_in.setValid();
         hdr.packet_in.ingress_port = std_md.ingress_port;
         }

   }

}


/*
 * V1Model EGRESS
 */

control ctl_egress(inout headers hdr,
                 inout metadata_t md,
                 inout standard_metadata_t std_md) {
   apply {
   }
}

/*
 * V1Model CHECKSUM COMPUTATION
 */
control ctl_compute_checksum(inout headers hdr, inout metadata_t md) {
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
        /*
        packet.emit(hdr.ethernet);
        packet.emit(hdr.llc_header);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.tcp);
        packet.emit(hdr.udp);
        */
        /*
         * emit hdr
         */
        packet.emit(hdr);
        /*
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.ipv6);
        packet.emit(hdr.llc_header);
        packet.emit(hdr.tcp);
        packet.emit(hdr.udp);
        packet.emit(hdr.mpls);
        */
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

