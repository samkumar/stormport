/*
 * "Copyright (c) 2008-2011 The Regents of the University  of California.
 * All rights reserved."
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 *
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 */

#include "IPDispatch.h"
#include "BlipStatistics.h"

/* IPDispatchP handles communicating with the 802.15.4 radio.
 * The upper layer of this module provides full IPv6 packets to the upper
 * layers.
 *
 * @author Stephen Dawson-Haggerty <stevedh@cs.berkeley.edu>
 */

configuration IPDispatchC {
  provides {
    interface SplitControl;
    interface IPLower;
    interface BlipStatistics<ip_statistics_t>;
    interface BlipStatistics<retry_statistics_t> as RetryStatistics;
  }
} implementation {

  components MainC;
  components NoLedsC as LedsC;

  /* IPDispatchP wiring -- fragment rassembly and lib6lowpan bindings */
  components IPDispatchP;

 #if defined(PLATFORM_MICAZ) || defined(PLATFORM_IRIS) || defined(PLATFORM_UCMINI) || defined(PLATFORM_STORM)
   components BareMessageC as MessageC;
 #elif defined(PLATFORM_TELOSB) || defined (PLATFORM_EPIC) || defined (PLATFORM_TINYNODE)
   components Ieee154BareC as MessageC;
 #else
   #warning "defaulting to Ieee154BareC for message"
   components Ieee154BareC as MessageC;
 #endif

  components RadioPacketMetadataC as PacketMetaC;
  components ReadLqiC;
  components new TimerMilliC() as ExpireTimer;
  components new TimerMilliC() as RetryStatTimer;

  SplitControl = IPDispatchP.SplitControl;
  IPLower = IPDispatchP.IPLower;
  BlipStatistics = IPDispatchP.BlipStatistics;
  RetryStatistics = IPDispatchP.RetryStatistics;

  /* Wire to the bare interfaces from the radio. Bare Ieee154 interfaces provide
   * full access to raw 802.15.4 packet and require that all fields of the
   * packet be set except for the sequence number and the CRC at the end. */
  IPDispatchP.Init <- MainC.SoftwareInit;
  IPDispatchP.RadioControl -> MessageC;
  IPDispatchP.BarePacket -> MessageC.BarePacket;
#if defined(PLATFORM_MICAZ) || defined(PLATFORM_IRIS) || defined(PLATFORM_UCMINI) || defined(PLATFORM_STORM)
  IPDispatchP.BareSend -> MessageC;
  IPDispatchP.BareReceive -> MessageC;
#elif defined(PLATFORM_TELOSB) || defined (PLATFORM_EPIC) || defined (PLATFORM_TINYNODE)
  IPDispatchP.Ieee154Send -> MessageC.BareSend;
  IPDispatchP.Ieee154Receive -> MessageC.BareReceive;
#else
  IPDispatchP.Ieee154Send -> MessageC.BareSend;
  IPDispatchP.Ieee154Receive -> MessageC.BareReceive;
#endif

#ifdef LOW_POWER_LISTENING
   IPDispatchP.LowPowerListening -> PacketMetaC.LowPowerListening;
#endif

  IPDispatchP.PacketLink -> PacketMetaC.PacketLink;
  IPDispatchP.ReadLqi -> ReadLqiC.ReadLqi;
  IPDispatchP.Leds -> LedsC.Leds;
  IPDispatchP.ExpireTimer -> ExpireTimer.Timer;
  IPDispatchP.RetryStatTimer -> RetryStatTimer.Timer;

  components new PoolC(message_t, N_FRAGMENTS) as FragPool;
  components new PoolC(struct send_entry, N_FRAGMENTS) as SendEntryPool;
  components new QueueC(struct send_entry *, N_FRAGMENTS);
  components new PoolC(struct send_info, N_CONCURRENT_SENDS) as SendInfoPool;

  IPDispatchP.FragPool -> FragPool.Pool;
  IPDispatchP.SendEntryPool -> SendEntryPool.Pool;
  IPDispatchP.SendInfoPool  -> SendInfoPool.Pool;
  IPDispatchP.SendQueue -> QueueC.Queue;

  components IPNeighborDiscoveryP;
  IPDispatchP.NeighborDiscovery -> IPNeighborDiscoveryP.NeighborDiscovery;

}
