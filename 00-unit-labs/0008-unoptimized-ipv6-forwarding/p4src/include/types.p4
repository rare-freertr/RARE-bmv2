#ifndef _TYPES_P4_
#define _TYPES_P4_

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
 * IPv6 address encoded using 128 bits
 */
typedef bit<128> ipv6_addr_t;

#endif // _TYPES_P4_
