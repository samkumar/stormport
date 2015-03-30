interface HplSam4lAESA
{
    command void DecryptMessage(uint32_t iv[4], uint16_t len, uint8_t *message, uint8_t *dest);
    event void DecryptionDone();
}
