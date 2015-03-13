configuration StormRoutingTableC
{
    provides interface Driver;
}
implementation
{
    components StormRoutingTableP;
    components IPStackC;
    StormRoutingTableP.ForwardingTable -> IPStackC;
    Driver = StormRoutingTableP;
}
