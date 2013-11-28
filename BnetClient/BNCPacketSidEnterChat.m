#import "BNCPacketSidEnterChat.h"

#import "NSMutableData+PacketBuffer.h"
#import "BNCChatConnection.h"

@interface BNCChatConnection ()

@property (readwrite, copy) NSString *username;

@end


@implementation BNCPacketSidEnterChat

- (NSString *)name
{
    return @"SID_ENTERCHAT";
}

- (long)identifier
{
    return SID_IDENTIFIER_BASE + SID_ENTERCHAT;
}

- (NSData *)bncsResponseForPacket:(NSMutableData *)packet forBattleNetConnection:(BNCChatConnection *)conn
{
    conn.username = [packet readString];
    LogMessageCompat(@"Entered chat as %@", conn.username);
    return nil;
}

@end
