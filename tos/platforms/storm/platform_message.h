

#ifndef PLATFORM_MESSAGE_H
#define PLATFORM_MESSAGE_H

#include <Serial.h>
#include <RF230Radio.h>

typedef union message_header {
	rf230packet_header_t rf230;
} message_header_t;

typedef union message_footer {
	rf230packet_footer_t rf230;
} message_footer_t;

typedef union message_metadata {
	rf230packet_metadata_t rf230;
} message_metadata_t;

#endif
