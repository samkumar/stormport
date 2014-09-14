
/*
 * @author Michael Andersen
 * @author Miklos Maroti
 */

configuration Ieee154MessageC
{
	provides
	{
		interface SplitControl;

		interface Ieee154Send;
		interface Receive as Ieee154Receive;
		interface SendNotifier;

		interface Packet;
		interface Ieee154Packet;
		interface Resource as SendResource[uint8_t clint];

		interface PacketAcknowledgements;
		interface LowPowerListening;
		interface PacketLink;
		interface RadioChannel;

		interface PacketTimeStamp<TMicro, uint32_t> as PacketTimeStampMicro;
		interface PacketTimeStamp<TMilli, uint32_t> as PacketTimeStampMilli;
	}
}

implementation
{
	components RF230Ieee154MessageC as MessageC;

	SplitControl = MessageC;

	Ieee154Send = MessageC;
	Ieee154Receive = MessageC;
	SendNotifier = MessageC;

	Packet = MessageC;
	Ieee154Packet = MessageC;
	SendResource = MessageC;

	PacketAcknowledgements = MessageC;
	LowPowerListening = MessageC;
	PacketLink = MessageC;
	RadioChannel = MessageC;

	PacketTimeStampMilli = MessageC;
	PacketTimeStampMicro = MessageC;
}