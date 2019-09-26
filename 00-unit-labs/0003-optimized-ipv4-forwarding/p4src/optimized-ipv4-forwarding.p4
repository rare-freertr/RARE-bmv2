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
 * IPv4 address encoded using 32 bits
 */
typedef bit<32> ipv4_addr_t;

/*
 * Nexthop using 16 bits
 */

typedef bit<16> nexthop_id_t;

/*
 * Ethernet header: as a header type, order matters
 */
header ethernet_t {
   mac_addr_t dst_mac_addr;
   mac_addr_t src_mac_addr;
   bit<16>   ethertype;
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
   ipv4_addr_t src_ipv4_addr;
   ipv4_addr_t dst_ipv4_addr;
}

/*
 * Instantiate metadata type  
 */
struct metadata_t {
   nexthop_id_t nexthop_id;
}

/*
 * Our P4 program header structure 
 */
struct headers {
   ethernet_t   ethernet;
   ipv4_t       ipv4;
}

/*
 * V1Model PARSER
 */
parser prs_main(packet_in packet,
                out headers hdr,
                inout metadata_t metadata,
                inout standard_metadata_t standard_metadata) {

   state start {
      packet.extract(hdr.ethernet);
      transition select(hdr.ethernet.ethertype) {
         ETHERTYPE_IPV4: prs_ipv4;
         default: accept;
      }
   }

   state prs_ipv4 {
      packet.extract(hdr.ipv4);
      transition accept;
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
                  inout metadata_t metadata,
                  inout standard_metadata_t standard_metadata) {

   /*
    * Discard via V1Model mark_to_drop()
    */
   action act_ipv4_fib_discard() {
      mark_to_drop();
   }


   /*
    * Perform L3 forwarding
    */
   action act_ipv4_fib_hit(mac_addr_t dst_mac_addr, egress_spec_t egress_port) {
      /*
       * the packet header src_mac is now set to the previous header dst_mac
       */
      hdr.ethernet.src_mac_addr = hdr.ethernet.dst_mac_addr;

      /*
       * the new packet header dst_mac is now the dst_mac 
       * set by the control plane entry
       */
      hdr.ethernet.dst_mac_addr = dst_mac_addr;

      /*
       * the egress_spec port is set now the egress_port 
       * set by the control plane entry
       */
      standard_metadata.egress_spec = egress_port;

      /*
       * We decrement the TTL
       */
      hdr.ipv4.ttl = hdr.ipv4.ttl -1;
   }

   /*
    * IPv4 nexthop processing
    * output value will be the input lkp key of act_nexthop table
    */
   action act_ipv4_set_nexthop(nexthop_id_t nexthop_id) {
      /*
       * Store nexthop value in nexthop_id
       */
      metadata.nexthop_id = nexthop_id;
   }

   table tbl_ipv4_fib_host {
      key = {
         /*
          * we match /32 host route
          */
         hdr.ipv4.dst_ipv4_addr: exact;
      }
      actions = {
         act_ipv4_set_nexthop;
         NoAction;
      }
      size = IPV4_HOST_TABLE_SIZE;
      default_action = NoAction();
   }

   table tbl_ipv4_fib_lpm {
      key = {
         /*
          * we match network route via Long Prefix Match kind operation
          */
         hdr.ipv4.dst_ipv4_addr: lpm;
      }
      actions = {
         act_ipv4_set_nexthop;
         NoAction;
      }
      size = IPV4_LPM_TABLE_SIZE;
      default_action = NoAction();
   }

   table tbl_nexthop {
      /*
       * custom metadat is used for the lookup key
       */
      key = {
         metadata.nexthop_id: exact;
      }
      actions = {
         act_ipv4_fib_hit;
         act_ipv4_fib_discard;
      }
      size = NEXTHOP_TABLE_SIZE;
      default_action = act_ipv4_fib_discard();
   }

   apply {
      /* 
       * if the packet is not valid we don't process it
       * proposed improvement: TTL check <> 0 
       */
      if (hdr.ipv4.isValid()) {
         /*
          * we first consider host routes
          */
         if (!tbl_ipv4_fib_host.apply().hit) {
            /* 
             * if no match consider LPM table
             */
             tbl_ipv4_fib_lpm.apply();
         }
         /*
          * nexthop value is now identified 
          * and stored in custom nexthop_id used for the lookup
          */
         tbl_nexthop.apply();
      }
   }
}

/*
 * V1Model EGRESS
 */

control ctl_egress(inout headers hdr,
                 inout metadata_t metadata,
                 inout standard_metadata_t standard_metadata) {
   apply {
   }
}

/*
 * V1Model CHECKSUM COMPUTATION
 */
control ctl_compute_checksum(inout headers hdr, inout metadata_t metadata) {
   apply {
      update_checksum(
         hdr.ipv4.isValid(),
            { hdr.ipv4.version,
	      hdr.ipv4.ihl,
              hdr.ipv4.diffserv,
              hdr.ipv4.total_len,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.frag_offset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.src_ipv4_addr,
              hdr.ipv4.dst_ipv4_addr },
              hdr.ipv4.hdr_checksum,
              HashAlgorithm.csum16);
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
        packet.emit(hdr.ipv4);

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
