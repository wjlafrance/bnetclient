#import "BNCPacketSidGetChannelList.h"

#import "NSMutableData+PacketBuffer.h"

@implementation BNCPacketSidGetChannelList

- (NSString *)name
{
    return @"SID_GETCHANNELLIST";
}

- (long)identifier
{
    return SID_IDENTIFIER_BASE + SID_GETCHANNELLIST;
}

- (NSData *)bncsResponseForPacket:(NSMutableData *)packet
           forBattleNetConnection:(BNCChatConnection *)__unused conn
{
    NSMutableArray *channels = [NSMutableArray new];
    
    while (true) {
        NSString *channelName = [packet readString];
        if (!channelName.length) {
            break;
        }
        [channels addObject:channelName];
    }
    LogMessageCompat(@"Channels as reported by server: %@", channels);
    
    return nil;
}

@end
