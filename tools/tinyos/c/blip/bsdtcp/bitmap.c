/* BITMAP */

void bmp_init(uint8_t* buf, size_t len) {
    memset(buf, 0x00, len);
}

#define _bmp_getrangeinfo(buf, start, len, first_bit_id, first_byte_ptr, last_bit_id, last_byte_ptr) \
    first_bit_id = (start & 0x7); \
    first_byte_ptr = buf + (start >> 3); \
    last_bit_id = (len & 0x7) + first_bit_id; \
    last_byte_ptr = first_byte_ptr + (len >> 3) + (last_bit_id >> 3); \
    last_bit_id &= 0x7;

/* Sets the specified range of bits. START is the index
   of the first bit to be set. LEN is the number of bits
   to be set. */
void bmp_setrange(uint8_t* buf, size_t start, size_t len) {
    uint8_t first_bit_id;
    uint8_t* first_byte_set;
    uint8_t last_bit_id;
    uint8_t* last_byte_set;
    uint8_t first_byte_mask, last_byte_mask;
    _bmp_getrangeinfo(buf, start, len, first_bit_id, first_byte_set,
                      last_bit_id, last_byte_set)
    
    first_byte_mask = (uint8_t) (0xFF >> first_bit_id);
    last_byte_mask = (uint8_t) (0xFF << (8 - last_bit_id));
    
    /* Set the bits. */
    if (first_byte_set == last_byte_set) {
        *first_byte_set |= (first_byte_mask & last_byte_mask);
    } else {
        *first_byte_set |= first_byte_mask;
        memset(first_byte_set + 1, 0xFF, last_byte_set - first_byte_set - 1);
        *last_byte_set |= last_byte_mask;
    }
}

/* Clears the specified range of bits. START is the index
   of the first bit to be cleared. LEN is the number of bits
   to be cleared. */
void bmp_clrrange(uint8_t* buf, size_t start, size_t len) {
    uint8_t first_bit_id;
    uint8_t* first_byte_clear;
    uint8_t last_bit_id;
    uint8_t* last_byte_clear;
    uint8_t first_byte_mask, last_byte_mask;
    _bmp_getrangeinfo(buf, start, len, first_bit_id, first_byte_clear,
                      last_bit_id, last_byte_clear)
                      
    first_byte_mask = (uint8_t) (0xFF << (8 - first_bit_id));
    last_byte_mask = (uint8_t) (0xFF >> last_bit_id);
    
    /* Clear the bits. */
    if (first_byte_clear == last_byte_clear) {
        *first_byte_clear &= (first_byte_mask | last_byte_mask);
    } else {
        *first_byte_clear &= first_byte_mask;
        memset(first_byte_clear + 1, 0x00, last_byte_clear - first_byte_clear - 1);
        *last_byte_clear &= last_byte_mask;
    }
}

/* Counts the number of set bits in BUF starting at START. BUF has length
   BUFLEN, in bytes. Counts the number of set bits until it either (1) finds
   a bit that isn't set, in which case it returns the number of set bits,
   (2) it has counted at least LIMIT bits, in which case it returns a number
   greater than or equal to LIMIT, or (3) reaches the end of the buffer, in
   which case it returns exactly the number of set bits it found. */
size_t bmp_countset(uint8_t* buf, size_t buflen, size_t start, size_t limit) {
    uint8_t first_bit_id;
    uint8_t first_byte;
    uint8_t ideal_first_byte;
    size_t numset;
    uint8_t curr_byte;
    size_t curr_index = start >> 3;
    first_bit_id = start & 0x7;
    first_byte = *(buf + curr_index);
    
    numset = 8 - first_bit_id; // initialize optimistically, assuming that the first byte will have all 1's in the part we care about
    ideal_first_byte = (uint8_t) (0xFF >> first_bit_id);
    first_byte &= ideal_first_byte;
    if (first_byte == ideal_first_byte) {
        // All bits in the first byte starting at first_bit_id are set
        for (curr_index = curr_index + 1; curr_index < buflen && numset < limit; curr_index++) {
            curr_byte = buf[curr_index];
            if (curr_byte == (uint8_t) 0xFF) {
                numset += 8;
            } else {
                while (curr_byte & (uint8_t) 0x80) { // we could add a numset < limit check here, but it probably isn't worth it
                    curr_byte <<= 1;
                    numset++;
                }
                break;
            }
        }
    } else {
        // The streak ends within the first byte
        do {
            first_byte >>= 1;
            ideal_first_byte >>= 1;
            numset--;
        } while (first_byte != ideal_first_byte);
    }
    return numset;
}

int bmp_isempty(uint8_t* buf, size_t buflen) {
    uint8_t* bufend = buf + buflen;
    while (buf < bufend) {
        if (*(buf++)) {
            return 0;
        }
    }
    return 1;
}

void bmp_print(uint8_t* buf, size_t buflen) {
    size_t i;
    for (i = 0; i < buflen; i++) {
        printf("%02X", buf[i]);
    }
    printf("\n");
}
