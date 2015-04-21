interface HplSam4lAESA
{
    command void DecryptMessage(uint8_t *iv, uint16_t len, uint8_t *message, uint8_t *dest);
    command void EncryptMessage(uint8_t *iv, uint16_t len, uint8_t *message, uint8_t *dest);
    command void SetKey(uint8_t *key);
}
