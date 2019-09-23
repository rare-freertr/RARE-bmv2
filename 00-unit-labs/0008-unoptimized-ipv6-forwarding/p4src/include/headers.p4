#ifndef _HEADERS_P4_
#define _HEADERS_P4_

#include <include/ethernet.p4>
#include <include/ipv6.p4>

struct headers {
    ethernet_t   ethernet;
    ipv6_t       ipv6;
}

#endif // _HEADERS_P4_
