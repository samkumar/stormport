
#ifndef __STORM_PRINTF__
#define __STORM_PRINTF__

#include <stdarg.h>

int storm_vsnprintf(char* buffer, unsigned int buffer_len, const char *fmt, va_list va);
int storm_snprintf(char* buffer, unsigned int buffer_len, const char *fmt, ...);
int storm_printf(const char *fmt, ...);
int storm_write(uint8_t const *buf, int len);

#define vsnprintf storm_vsnprintf
#define snprintf storm_snprintf
#define printf storm_printf

//Note these functions will only work on Storm if you are using
//GDB, and the Storm GDB init script (http://storm.rocks/
void storm_trace(const char*);
void storm_trace8(uint8_t );
void storm_trace16(uint16_t);
void storm_trace32(uint32_t);

#ifdef ENABLE_TRACE
#define trace(x) storm_trace((x))
#define trace8(x) storm_trace8((x))
#define trace16(x) storm_trace16((x))
#define trace32(x) storm_trace32((x))
#else
#define trace(x) for(;0;)
#define trace8(x) for(;0;)
#define trace16(x) for(;0;)
#define trace32(x) for(;0;)
#endif

#endif



