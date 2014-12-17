module EthernetClientResourceConfigureP
{
    provides interface ResourceConfigure[uint8_t id];
}
implementation
{
    async command void ResourceConfigure.configure[uint8_t id]()
    {
    }

    async command void ResourceConfigure.unconfigure[uint8_t id]()
    {
    }
}
