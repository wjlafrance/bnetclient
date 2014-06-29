#import "BNCPacketSidAuthInfo.h"

#import "NSMutableData+PacketBuffer.h"
#import "BNCChatConnection.h"

@interface BNCChatConnection ()

@property (readwrite, assign) uint32_t loginType;
@property (readwrite, assign) uint32_t serverToken;
@property (readwrite, assign) uint32_t mpqFiletime;
@property (readwrite, copy)   NSString *mpqFilename;
@property (readwrite, copy)   NSString *mpqFormula;

@end


@implementation BNCPacketSidAuthInfo

- (NSString *)name
{
    return @"SID_AUTH_INFO";
}

- (long)identifier
{
    return SID_IDENTIFIER_BASE + SID_AUTH_INFO;
}

- (NSData *)bnlsResponseForPacket:(NSMutableData *)packet forBattleNetConnection:(BNCChatConnection *)conn
{
    conn.loginType = [packet readUInt32];
    conn.serverToken = [packet readUInt32];
    [packet readUInt32]; // skip UDP value
    conn.mpqFiletime = [packet readUInt64];
    conn.mpqFilename = [packet readString];
    conn.mpqFormula  = [packet readString];
    
    NSLog(@"Hashing key: %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"cdkey"]);
    
    NSMutableData *response = [NSMutableData new];
    [response writeUInt32:conn.serverToken];
    [response writeString:[[NSUserDefaults standardUserDefaults] valueForKey:@"cdkey"]];
    return [response buildBnlsPacketWithID:BNLS_CDKEY];
}

@end
