configuration StormRoutingTableC
{
    provides interface Driver;
}
implementation
{
    components StormRoutingTableP;
    components IPStackC;
    StormRoutingTableP.ForwardingTable -> IPStackC;
    StormRoutingTableP.NeighborDiscovery -> IPStackC;
    Driver = StormRoutingTableP;
}
