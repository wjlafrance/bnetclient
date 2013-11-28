#import "BNCConstants.h"

@interface NSMutableData (PacketBuffer)

- (uint8_t)readUInt8;
- (uint16_t)readUInt16;
- (uint32_t)readUInt32;
- (uint64_t)readUInt64;
- (NSString *)readString;
- (NSString *)readStringWithLength:(NSUInteger)length;

- (void)writeUInt8:(uint8_t)value;
- (void)writeUInt16:(uint16_t)value;
- (void)writeUInt32:(uint32_t)value;
- (void)writeUInt64:(uint64_t)value;
- (void)writeString:(NSString *)string;
- (void)writeStringWithoutNullTerminator:(NSString *)string;

- (NSMutableData *)buildBncsPacketWithID:(BattleNetPacketIdentifier)packetId;
- (NSMutableData *)buildBnlsPacketWithID:(BnlsPacketIdentifier)packetId;
- (NSMutableData *)buildBnftpPacket;

@end
