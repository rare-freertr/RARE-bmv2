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
