#import "BNCPacketSidChatEvent.h"

#import "NSMutableData+PacketBuffer.h"
#import "BNCChatConnection.h"

@implementation BNCPacketSidChatEvent

- (NSString *)name
{
    return @"SID_CHATEVENT";
}

- (long)identifier
{
    return SID_IDENTIFIER_BASE + SID_CHATEVENT;
}

- (NSData *)bncsResponseForPacket:(NSMutableData *)packet forBattleNetConnection:(BNCChatConnection *)conn
{
    uint32_t eventid   = [packet readUInt32];
    uint32_t flags     = [packet readUInt32];
    uint32_t ping      = [packet readUInt32];
    [packet readUInt32];
    [packet readUInt32];
    [packet readUInt32];
    NSString *username = [packet readString];
    NSString *text     = [packet readString];
    
    [conn.delegate battleNetConnection:conn eventDidOccur:eventid username:username text:text flags:flags ping:ping];
    
    return nil;
}

@end
