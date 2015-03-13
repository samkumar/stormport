#include "driver.h"
#include <stdint.h>
#include <lib6lowpan/ip.h>
#include <iprouting.h>

module StormRoutingTableP
{
    provides interface Driver;
    uses interface ForwardingTable;
}
implementation
{
    command driver_callback_t Driver.peek_callback()
    {
        return NULL;
    }

    command void Driver.pop_callback() {}

    async command syscall_rv_t Driver.syscall_ex(
        uint32_t number, uint32_t arg0, 
        uint32_t arg1, uint32_t arg2, 
        uint32_t *argx)
    {
        switch(number & 0xFF)
        {
                   //              arg0            arg1        arg2      argx[0]
        case 0x01: //add_route(ip address prefix, prefix len, nexthop, interface) -> error or route index
        {
            struct in6_addr _next_hop;
            struct in6_addr *next_hop = &_next_hop;
            struct in6_addr _prefix;
            struct in6_addr *prefix = &_prefix;
            uint8_t ifindex;

            int prefix_len_bits = (int)arg1; // prefix len

            // check next hop for NULL. If not null, parse it
            if ((char*)arg2 == NULL)
            {
                next_hop = NULL;
            }
            else
            {
                inet_pton6((char*)arg2, next_hop); // prefix
            }

            // do the same for the prefix
            if ((char*)arg0 == NULL)
            {
                prefix = NULL;
            }
            else
            {
                inet_pton6((char*)arg0, prefix); // prefix
            }

            // check for valid interface
            if (argx[0] > 3) // invalid iface
            {
                return -1; // error
            }
            else
            {
                ifindex = (uint8_t) argx[0]; // iface index
            }
            // returns the route_key_t, an int
            if (prefix == NULL)
            {
                return call ForwardingTable.addRoute(NULL, prefix_len_bits, next_hop, ifindex);
            }
            else
            {
                return call ForwardingTable.addRoute(prefix->s6_addr, prefix_len_bits, next_hop, ifindex);
            }
        }
                   //           arg0
        case 0x02: //del_route(route key (int)) -> error
        {
            route_key_t index = (route_key_t) arg0;
            return call ForwardingTable.delRoute(index);
        }

                   //             arg0             arg1
        case 0x03: //get_route(route key (int), return buffer uint8_t [16] (just prefix for now) )
        {
            route_key_t index = (route_key_t) arg0;
            struct route_entry *entry = call ForwardingTable.lookupRouteKey(index);
            int i;
            for (i=0;i<16;i++)
            {
                ((uint8_t *)arg1)[i] = entry->prefix.s6_addr[i];
            }
            return 0;
        }

        case 0x04: //lookup_route(prefix, prefix_len_bits, return buffer uint8_t)
        {
            int i;
            struct route_entry *entry;
            struct in6_addr _prefix;
            struct in6_addr *prefix = &_prefix;
            int prefix_len_bits = (int)arg1; // prefix len
            // check prefix
            if ((char*)arg0 == NULL)
            {
                prefix = NULL;
            }
            else
            {
                inet_pton6((char*)arg0, prefix); // prefix
            }

            if (prefix == NULL)
            {
                entry = call ForwardingTable.lookupRoute(NULL, prefix_len_bits);
            }
            else
            {
                entry = call ForwardingTable.lookupRoute(prefix->s6_addr, prefix_len_bits);
            }
            for (i=0;i<16;i++)
            {
                ((uint8_t *)arg2)[i] = entry->prefix.s6_addr[i];
            }
            return 0;
        }
        }
    }
}
