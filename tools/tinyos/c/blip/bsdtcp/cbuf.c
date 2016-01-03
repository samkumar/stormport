/* CIRCULAR BUFFER */
#include "bitmap.h"

struct circbuf_header {
    size_t r_index;
    size_t w_index;
    size_t size;
} __attribute__((packed));

int cbuf_init(uint8_t* buf, size_t len) {
    struct circbuf_header* chdr = (struct circbuf_header*) buf;
    if (len < sizeof(struct circbuf_header)) {
        return -1;
    }
    chdr->r_index = 0;
    chdr->w_index = 0;
    chdr->size = len - sizeof(struct circbuf_header);
    return 0;
}

size_t _cbuf_used_space(struct circbuf_header* chdr) {
    if (chdr->w_index >= chdr->r_index) {
        return chdr->w_index - chdr->r_index;
    } else {
        return chdr->size + chdr->w_index - chdr->r_index;
    }
}

size_t cbuf_used_space(uint8_t* buf) {
    struct circbuf_header* chdr = (struct circbuf_header*) buf;
    return _cbuf_used_space(chdr);
}

/* There's always one byte of lost space so I can distinguish between a full
   buffer and an empty buffer. */
size_t _cbuf_free_space(struct circbuf_header* chdr) {
    return chdr->size - 1 - _cbuf_used_space(chdr);
}

size_t cbuf_free_space(uint8_t* buf) {
    struct circbuf_header* chdr = (struct circbuf_header*) buf;
    return _cbuf_free_space(chdr);
}

size_t cbuf_size(uint8_t* buf) {
    struct circbuf_header* chdr = (struct circbuf_header*) buf;
    return chdr->size - 1;
}

size_t cbuf_write(uint8_t* buf, uint8_t* data, size_t data_len) {
    struct circbuf_header* chdr = (struct circbuf_header*) buf;
    size_t free_space = _cbuf_free_space(chdr);
    uint8_t* buf_data;
    size_t fw_index;
    size_t bytes_to_end;
    if (free_space < data_len) {
        data_len = free_space;
    }
    buf_data = (uint8_t*) (chdr + 1);
    fw_index = (chdr->w_index + data_len) % chdr->size;
    if (fw_index >= chdr->w_index) {
        memcpy(buf_data + chdr->w_index, data, data_len);
    } else {
        bytes_to_end = chdr->size - chdr->w_index;
        memcpy(buf_data + chdr->w_index, data, bytes_to_end);
        memcpy(buf_data, data + bytes_to_end, data_len - bytes_to_end);
    }
    chdr->w_index = fw_index;
    return data_len;
}

void _cbuf_read_unsafe(struct circbuf_header* chdr, uint8_t* data,
                       size_t numbytes, int pop) {
    uint8_t* buf_data = (uint8_t*) (chdr + 1);
    size_t fr_index = (chdr->r_index + numbytes) % chdr->size;
    size_t bytes_to_end;
    if (fr_index >= chdr->r_index) {
        memcpy(data, buf_data + chdr->r_index, numbytes);
    } else {
        bytes_to_end = chdr->size - chdr->r_index;
        memcpy(data, buf_data + chdr->r_index, bytes_to_end);
        memcpy(data + bytes_to_end, buf_data, numbytes - bytes_to_end);
    }
    if (pop) {
        chdr->r_index = fr_index;
    }
}

size_t cbuf_read(uint8_t* buf, uint8_t* data, size_t numbytes, int pop) {
    struct circbuf_header* chdr = (struct circbuf_header*) buf;
    size_t used_space = _cbuf_used_space(chdr);
    if (used_space < numbytes) {
        numbytes = used_space;
    }
    _cbuf_read_unsafe(chdr, data, numbytes, pop);
    return numbytes;
}

size_t cbuf_read_offset(uint8_t* buf, uint8_t* data, size_t numbytes, size_t offset) {
    struct circbuf_header* chdr = (struct circbuf_header*) buf;
    size_t used_space = _cbuf_used_space(chdr);
    size_t oldpos;
    if (used_space <= offset) {
        return 0;
    } else if (used_space < offset + numbytes) {
        numbytes = used_space - offset;
    }
    oldpos = chdr->r_index;
    chdr->r_index = (chdr->r_index + offset) % chdr->size;
    _cbuf_read_unsafe(chdr, data, numbytes, 0);
    chdr->r_index = oldpos;
    return numbytes;    
}

size_t cbuf_pop(uint8_t* buf, size_t numbytes) {
    struct circbuf_header* chdr = (struct circbuf_header*) buf;
    size_t used_space = _cbuf_used_space(chdr);
    if (used_space < numbytes) {
        numbytes = used_space;
    }
    chdr->r_index = (chdr->r_index + numbytes) % chdr->size;
    return numbytes;
}

/* Writes DATA to the unused portion of the buffer, at the position OFFSET past
   the end of the buffer. BITMAP is updated by setting bits according to which
   bytes now contain data.
   The index of the first byte written is stored into FIRSTINDEX, if it is not
   NULL. */
size_t cbuf_reass_write(uint8_t* buf, size_t offset, uint8_t* data, size_t numbytes, uint8_t* bitmap, size_t* firstindex) {
    struct circbuf_header* chdr = (struct circbuf_header*) buf;
    uint8_t* buf_data = (uint8_t*) (chdr + 1);
    size_t free_space = _cbuf_free_space(chdr);
    size_t start_index;
    size_t end_index;
    size_t bytes_to_end;
    if (offset > free_space) {
        return 0;
    } else if (offset + numbytes > free_space) {
        numbytes = free_space - offset;
    }
    start_index = (chdr->w_index + offset) % chdr->size;
    end_index = (start_index + numbytes) % chdr->size;
    if (end_index >= start_index) {
        memcpy(buf_data + start_index, data, numbytes);
        if (bitmap) {
            bmp_setrange(bitmap, start_index, numbytes);
        }
    } else {
        bytes_to_end = chdr->size - start_index;
        memcpy(buf_data + start_index, data, bytes_to_end);
        memcpy(buf_data, data + bytes_to_end, numbytes - bytes_to_end);
        if (bitmap) {
            bmp_setrange(bitmap, start_index, bytes_to_end);
            bmp_setrange(bitmap, 0, numbytes - bytes_to_end);
        }
    }
    if (firstindex) {
        *firstindex = start_index;
    }
    return numbytes;
}

/* Writes NUMBYTES bytes to the buffer. The bytes are taken from the unused
   space of the buffer, and can be set using cbuf_reass_write. */
size_t cbuf_reass_merge(uint8_t* buf, size_t numbytes, uint8_t* bitmap) {
    struct circbuf_header* chdr = (struct circbuf_header*) buf;
    size_t old_w = chdr->w_index;
    size_t free_space = _cbuf_free_space(chdr);
    size_t bytes_to_end;
    if (numbytes > free_space) {
        numbytes = free_space;
    }
    chdr->w_index = (chdr->w_index + numbytes) % chdr->size;
    if (bitmap) {
        if (chdr->w_index >= old_w) {
            bmp_clrrange(bitmap, old_w, numbytes);
        } else {
            bytes_to_end = chdr->size - old_w;
            bmp_clrrange(bitmap, old_w, bytes_to_end);
            bmp_clrrange(bitmap, 0, numbytes - bytes_to_end);
        }
    }
    return numbytes;
}

size_t cbuf_reass_count_set(uint8_t* buf, size_t offset, uint8_t* bitmap, size_t limit) {
    struct circbuf_header* chdr = (struct circbuf_header*) buf;
    size_t bitmap_size = (chdr->size >> 3) + ((chdr->size & 0x7) ? 1 : 0);
    size_t until_end;
    offset = (chdr->w_index + offset) % chdr->size;
    until_end = bmp_countset(bitmap, bitmap_size, offset, limit);
    if (until_end >= limit || until_end < (chdr->size - offset)) {
        // If we already hit the limit, or if the streak ended before wrapping, then stop here
        return until_end;
    }
    limit -= until_end; // effectively, this is our limit when continuing
    // Continue until either the new limit or until we have scanned OFFSET bits (if we scan more than OFFSET bits, we'll wrap and scan some parts twice)
    return until_end + bmp_countset(bitmap, bitmap_size, 0, limit < offset ? limit : offset);
}

/* Returns a true value iff INDEX is the index of a byte within OFFSET bytes
   past the end of the buffer. */
int cbuf_reass_within_offset(uint8_t* buf, size_t offset, size_t index) {
    struct circbuf_header* chdr = (struct circbuf_header*) buf;
    size_t range_start = chdr->w_index;
    size_t range_end = (range_start + offset) % chdr->size;
    if (range_end >= range_start) {
        return index >= range_start && index < range_end;
    } else {
        return index < range_end || (index >= range_start && index < chdr->size);
    }
}

#if 0 // The segment functionality doesn't look like it's going to be used

/* Reads NBYTES bytes of the first segment into BUF. If there aren't NBYTES
   to read in the buffer, does nothing and returns 0. Otherwise, returns
   the number of bytes read. */
size_t cbuf_peek_segment(uint8_t* buf, uint8_t* data, size_t numbytes) {
    struct circbuf_header* chdr = (struct circbuf_header*) buf;
    size_t used_space = _cbuf_used_space(chdr);
    size_t old_ridx;
    if (used_space < numbytes + sizeof(size_t)) {
        return 0;
    }
    old_ridx = chdr->r_index;
    chdr->r_index = (chdr->r_index + sizeof(size_t)) % chdr->size;
    _cbuf_read_unsafe(chdr, data, numbytes, 0);
    chdr->r_index = old_ridx;
    return numbytes;
}


int cbuf_write_segment(uint8_t* buf, uint8_t* segment, size_t seglen) {
    struct circbuf_header* chdr = (struct circbuf_header*) buf;
    if (_cbuf_free_space(chdr) < seglen + sizeof(seglen)) {
        return -1;
    }
    cbuf_write(buf, (uint8_t*) &seglen, sizeof(seglen));
    cbuf_write(buf, segment, seglen);
    return 0;
}

size_t cbuf_peek_segment_size(uint8_t* buf) {
    size_t segsize;
    if (cbuf_read(buf, (uint8_t*) &segsize,
                  sizeof(size_t), 0) < sizeof(size_t)) {
        return 0;
    }
    return segsize;
}

size_t cbuf_pop_segment(uint8_t* buf, size_t segsize) {
    if (!segsize) {
        segsize = cbuf_peek_segment_size(buf);
    }
    return cbuf_pop(buf, segsize + sizeof(size_t));
}

#endif
