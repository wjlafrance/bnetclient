#import "NSMutableData+PacketBuffer.h"

#define POP_INT(type) type ret; memcpy(&ret, self.bytes, sizeof(ret)); [self removeBytes:sizeof(ret)]; return ret;
#define PUSH_INT [self appendBytes:&value length:sizeof(value)];

@implementation NSMutableData (PacketBuffer)

- (void)removeBytes:(NSUInteger)count
{
    [self replaceBytesInRange:NSMakeRange(0, count) withBytes:NULL length:0];
}

- (uint8_t)readUInt8 { POP_INT(uint8_t) }

- (uint16_t)readUInt16 { POP_INT(uint16_t) }

- (uint32_t)readUInt32 { POP_INT(uint32_t) }

- (uint64_t)readUInt64 { POP_INT(uint64_t) }

- (NSString *)readString
{
    NSString *ret = [NSString stringWithCString:self.bytes encoding:NSASCIIStringEncoding];
    [self removeBytes:[ret length] + 1];
    return ret;
}

- (NSString *)readStringWithLength:(NSUInteger)length
{
    char str[length + 1];
    memcpy(str, self.bytes, length);
    str[length] = 0;
    [self removeBytes:length];
    return [NSString stringWithCString:str encoding:NSASCIIStringEncoding];
}

- (void)writeUInt8:(uint8_t)value
{
    [self appendBytes:&value length:sizeof(value)];
}

- (void)writeUInt16:(uint16_t)value
{
    [self appendBytes:&value length:sizeof(value)];
}

- (void)writeUInt32:(uint32_t)value
{
    [self appendBytes:&value length:sizeof(value)];
}

- (void)writeUInt64:(uint64_t)value
{
    [self appendBytes:&value length:sizeof(value)];
}

- (void)writeString:(NSString *)string
{
    [self writeStringWithoutNullTerminator:string];
    [self writeUInt8:0];
}

- (void)writeStringWithoutNullTerminator:(NSString *)string
{
    [self appendBytes:[string cStringUsingEncoding:NSASCIIStringEncoding] length:string.length];
}

/**
 * BNCS Packet Header:
 * uint8  0xFF
 * uint8  Packet ID
 * uint16 Length including header
 */
- (instancetype)buildBncsPacketWithID:(BattleNetPacketIdentifier)packetId
{
    NSMutableData *bncsPacket = [[NSMutableData alloc] initWithCapacity:self.length + 4];
    [bncsPacket writeUInt8:0xFF];
    [bncsPacket writeUInt8:packetId];
    [bncsPacket writeUInt16:self.length + 4];
    [bncsPacket appendData:self];
    return bncsPacket;
}

/**
 * BNLS Packet Header:
 * uint16 Length including header
 * uint8  Packet ID
 */
- (instancetype)buildBnlsPacketWithID:(BnlsPacketIdentifier)packetId
{
    NSMutableData *bnlsPacket = [[NSMutableData alloc] initWithCapacity:self.length + 3];
    [bnlsPacket writeUInt16:self.length + 3];
    [bnlsPacket writeUInt8:packetId];
    [bnlsPacket appendData:self];
    return bnlsPacket;
}

- (instancetype)buildBnftpPacket
{
    NSMutableData *bnftpPacket = [[NSMutableData alloc] initWithCapacity:self.length + 4];
    [bnftpPacket writeUInt16:self.length + 4];
    [bnftpPacket writeUInt16:0x100];
    [bnftpPacket appendData:self];
    return bnftpPacket;
}

@end
