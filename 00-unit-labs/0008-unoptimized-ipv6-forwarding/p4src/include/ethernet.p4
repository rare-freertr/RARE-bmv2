#ifndef _ETHERNET_P4_
#define _ETHERNET_P4_

#include <include/types.p4>

/*
 * Ethernet header: as a header type, order matters
 */
header ethernet_t {
   mac_addr_t dst_mac_addr;
   mac_addr_t src_mac_addr;
   bit<16>   ethertype;
}

#endif // _ETHERNET_P4_
