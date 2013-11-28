#import "BNCPacketBnlsCdkey.h"

#import "BattleNetProduct.h"
#import "NSMutableData+PacketBuffer.h"
#import "BNCChatConnection.h"

@interface BNCChatConnection ()

@property (readwrite, assign) uint32_t clientToken;
@property (readwrite, copy)   NSData *hashedKey;

@end


@implementation BNCPacketBnlsCdkey

- (NSString *)name
{
    return @"BNLS_CDKEY";
}

- (long)identifier
{
    return BNLS_IDENTIFIER_BASE + BNLS_CDKEY;
}

- (NSData *)bnlsResponseForPacket:(NSMutableData *)packet forBattleNetConnection:(BNCChatConnection *)conn
{
    if (0 == [packet readUInt32]) {
        [conn.delegate battleNetConnection:conn didFailToAuthenticateClientToService:BNCS
                                 withError:@"BNLS failed to hash CD-Key."];
        [conn.bncsSocket disconnect];
        [conn.bnlsSocket disconnect];
        return nil;
    }
    conn.clientToken = [packet readUInt32];
    conn.hashedKey = [packet subdataWithRange:NSMakeRange(0, 9 * sizeof(uint32_t))];
    
    NSMutableData *response = [NSMutableData new];
    [response writeUInt32:[BattleNetProduct currentProduct].bnlsProductCode];
    [response writeUInt32:0];
    [response writeUInt32:0];
    [response writeUInt64:conn.mpqFiletime]; // MPQ Filetime
    [response writeString:conn.mpqFilename]; // MPQ Filename
    [response writeString:conn.mpqFormula];  // Value String
    return [response buildBnlsPacketWithID:BNLS_VERSIONCHECKEX2];
}

@end
