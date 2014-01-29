#import "BNCPacketBnlsVersionCheckEx2.h"

#import "NSMutableData+PacketBuffer.h"
#import "BNCChatConnection.h"

@implementation BNCPacketBnlsVersionCheckEx2

- (NSString *)name
{
    return @"BNLS_VERSIONCHECKEX2";
}

- (long)identifier
{
    return BNLS_IDENTIFIER_BASE + BNLS_VERSIONCHECKEX2;
}

- (NSData *)bncsResponseForPacket:(NSMutableData *)packet forBattleNetConnection:(BNCChatConnection *)conn
{
    if (0 == [packet readUInt32]) {
        [conn.delegate battleNetConnection:conn didFailToAuthenticateClientToService:BNCS
                                 withError:@"BNLS failed version check."];
        [conn disconnect];
    }
    
    NSMutableData *response = [NSMutableData new];
    [response writeUInt32:conn.clientToken];
    [response writeUInt32:[packet readUInt32]]; // EXE Version
    [response writeUInt32:[packet readUInt32]]; // Checksum
    [response writeUInt32:1]; // Number of CD Keys
    [response writeUInt32:0]; // Not using spawn
    [response appendData:conn.hashedKey];
    [response writeString:[packet readString]]; // EXE Statstring
    [response writeString:[UIDevice currentDevice].name];
    return [response buildBncsPacketWithID:SID_AUTH_CHECK];
}


@end
