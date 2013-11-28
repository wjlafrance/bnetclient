#import "BNCPacketSidPing.h"

#import "NSMutableData+PacketBuffer.h"

@implementation BNCPacketSidPing

- (NSString *)name
{
    return @"SID_PING";
}

- (long)identifier
{
    return SID_IDENTIFIER_BASE + SID_PING;
}

- (NSData *)bncsResponseForPacket:(NSMutableData *)packet forBattleNetConnection:(BNCChatConnection *)__unused conn
{
    return [packet buildBncsPacketWithID:SID_PING];
}

@end
