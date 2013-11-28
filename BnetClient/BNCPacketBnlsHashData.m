#import "BNCPacketBnlsHashData.h"

#import "NSMutableData+PacketBuffer.h"
#import "BNCChatConnection.h"

@implementation BNCPacketBnlsHashData

- (NSString *)name
{
    return @"BNLS_HASHDATA";
}

- (long)identifier
{
    return BNLS_IDENTIFIER_BASE + BNLS_HASHDATA;
}

- (NSData *)bncsResponseForPacket:(NSMutableData *)packet forBattleNetConnection:(BNCChatConnection *)conn
{
    NSMutableData *response = [NSMutableData new];
    [response writeUInt32:conn.clientToken];
    [response writeUInt32:conn.serverToken];
    for (int i = 0; i < 5; i++) { // Password hash
        [response writeUInt32:[packet readUInt32]];
    }
    [response writeString:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"]];
    [conn.delegate battleNetConnection:conn didBeginAuthenticatingUserToService:BNCS];
    return [response buildBncsPacketWithID:SID_LOGONRESPONSE];
}

@end
