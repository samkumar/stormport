interface EthernetShieldConfig
{
    command void initialize(uint32_t src_ip, uint32_t netmask, uint32_t gateway, uint8_t *mac);
    // break out init method from socketP
}

