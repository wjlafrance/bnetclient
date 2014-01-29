#import "BNCPacketSidAuthCheck.h"

#import "NSData+BrokenSHA1.h"
#import "NSMutableData+PacketBuffer.h"
#import "BNCChatConnection.h"

@implementation BNCPacketSidAuthCheck

- (NSString *)name
{
    return @"SID_AUTH_CHECK";
}

- (long)identifier
{
    return SID_IDENTIFIER_BASE + SID_AUTH_CHECK;
}

- (NSData *)bncsResponseForPacket:(NSMutableData *)packet forBattleNetConnection:(BNCChatConnection *)conn
{
    uint32_t result = [packet readUInt32];
    NSString *additionalInformation = [packet readString];
    
    switch (result) {
        case 0x000: {
            [conn.delegate battleNetConnection:conn didAuthenticateClientToService:BNCS];
            
            NSString *username = [NSUserDefaults.standardUserDefaults valueForKey:@"username"];
            NSString *password = [NSUserDefaults.standardUserDefaults valueForKey:@"password"];
            
            NSMutableData *response = [NSMutableData new];
            [response writeUInt32:conn.clientToken];
            [response writeUInt32:conn.serverToken];
            
            NSMutableData *hashBuffer = [NSMutableData new];
            [hashBuffer writeStringWithoutNullTerminator:[password lowercaseString]];
            [response appendData:[hashBuffer doubleBrokenSha1HashWithClientToken:conn.clientToken
                                                                  andServerToken:conn.serverToken]];
            
            [response writeString:username];
            [conn.delegate battleNetConnection:conn didBeginAuthenticatingUserToService:BNCS];
            return [response buildBncsPacketWithID:SID_LOGONRESPONSE2];
        }
        
        case 0x100:
            [conn.delegate battleNetConnection:conn didFailToAuthenticateClientToService:BNCS
                                     withError:[NSString stringWithFormat:@"Old game version. Update MPQ: %@", additionalInformation]];
            break;
            
        case 0x101:
            [conn.delegate battleNetConnection:conn didFailToAuthenticateClientToService:BNCS
                                     withError:@"Invalid version."];
            break;
            
        case 0x102:
            [conn.delegate battleNetConnection:conn didFailToAuthenticateClientToService:BNCS
                                     withError:[NSString stringWithFormat:@"Game version too new. Downgrade MPQ: %@", additionalInformation]];
            break;
            
        case 0x200:
            [conn.delegate battleNetConnection:conn didFailToAuthenticateClientToService:BNCS
                                     withError:@"Invalid CD-Key."];
            break;
            
        case 0x201:
            [conn.delegate battleNetConnection:conn didFailToAuthenticateClientToService:BNCS
                                     withError:[NSString stringWithFormat:@"CD-Key is in use by %@.", additionalInformation]];
            break;
            
        case 0x202:
            [conn.delegate battleNetConnection:conn didFailToAuthenticateClientToService:BNCS
                                     withError:@"CD-Key is banned."];
            break;
            
        case 0x203:
            [conn.delegate battleNetConnection:conn didFailToAuthenticateClientToService:BNCS
                                     withError:@"CD-Key has wrong product code."];
            break;
            
        default:
            [conn.delegate battleNetConnection:conn didFailToAuthenticateClientToService:BNCS
                                     withError:[NSString stringWithFormat:@"Authorization error code 0x%X (%@)", result, additionalInformation]];
            break;
    }
    
    [conn disconnect];
    return nil;
}

@end
