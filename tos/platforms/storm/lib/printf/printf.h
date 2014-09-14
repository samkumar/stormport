
#ifndef __STORM_PRINTF__
#define __STORM_PRINTF__

#include <stdarg.h>

int storm_vsnprintf(char* buffer, unsigned int buffer_len, const char *fmt, va_list va);
int storm_snprintf(char* buffer, unsigned int buffer_len, const char *fmt, ...);
int storm_printf(const char *fmt, ...);

#define vsnprintf storm_vsnprintf
#define snprintf storm_snprintf
#define printf storm_printf

#endif



