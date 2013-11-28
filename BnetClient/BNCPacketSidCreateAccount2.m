#import "BNCPacketSidCreateAccount2.h"

#import "BNCChatConnection.h"
#import "NSMutableData+PacketBuffer.h"
#import "NSData+BrokenSHA1.h"

const uint32_t RESPONSE_ACCOUNTCREATED = 0;
const uint32_t RESPONSE_NAMETOOSHORT = 1;
const uint32_t RESPONSE_NAMECONTAINEDINVALIDCHARACTERS = 2;
const uint32_t RESPONSE_NAMECONTAINEDBANNEDWORD = 3;
const uint32_t RESPONSE_ACCOUNTALREADYEXISTS = 4;
const uint32_t RESPONSE_ACCOUNTSTILLBEINGCREATED = 5;
const uint32_t RESPONSE_NOTENOUGHALPHANUMERICCHARACTERS = 6;
const uint32_t RESPONSE_NAMECONTAINEDAJACENTPUNCTUATIONCHARACTERS = 7;
const uint32_t RESPONSE_NAMECONTAINEDTOOMANYPUNCTIONATIONCHARACTERS = 8;

@implementation BNCPacketSidCreateAccount2

- (NSString *)name
{
    return @"SID_CREATEACCOUNT2";
}

- (long)identifier
{
    return SID_IDENTIFIER_BASE + SID_CREATEACCOUNT2;
}

- (NSData *)bncsResponseForPacket:(NSMutableData *)packet
           forBattleNetConnection:(BNCChatConnection *)conn
{
    uint32_t result = [packet readUInt32];
    NSString *nameSuggestion = [packet readString];
    
    switch (result) {
        case RESPONSE_ACCOUNTCREATED:
            [conn.delegate battleNetConnection:conn didCreateAccountForService:BNCS];
            [conn.delegate battleNetConnection:conn didBeginAuthenticatingUserToService:BNCS];
            return [self createLogonResponseForConnection:conn];
            
        case RESPONSE_ACCOUNTALREADYEXISTS:
            [conn.delegate battleNetConnection:conn didFailToAuthenticateUserToService:BNCS
                                    withError:@"Couldn't create account -- account already exists."];
            [conn.bncsSocket disconnect];
            return nil;
            
        case RESPONSE_ACCOUNTSTILLBEINGCREATED:
            [conn.delegate battleNetConnection:conn didFailToAuthenticateUserToService:BNCS
                                     withError:@"Account still being created."];
            [conn.bncsSocket disconnect];
            return nil;
            
        case RESPONSE_NAMETOOSHORT:
        case RESPONSE_NAMECONTAINEDINVALIDCHARACTERS:
        case RESPONSE_NAMECONTAINEDBANNEDWORD:
        case RESPONSE_NOTENOUGHALPHANUMERICCHARACTERS:
        case RESPONSE_NAMECONTAINEDAJACENTPUNCTUATIONCHARACTERS:
        case RESPONSE_NAMECONTAINEDTOOMANYPUNCTIONATIONCHARACTERS: {
            NSString *reason = [NSString stringWithFormat:@"Could not create account because the name is invalid (code %d)."
                                @"The server suggested \"@%@\".", result, nameSuggestion];
            [conn.delegate battleNetConnection:conn didFailToAuthenticateUserToService:BNCS withError:reason];
            [conn.bncsSocket disconnect];
            return nil;
        }
            
        default: {
            NSString *reason = [NSString stringWithFormat:@"Server gave illegal response to SID_CREATEACCOUNT2: 0x%X", result];
            [conn.delegate battleNetConnection:conn didFailToAuthenticateUserToService:BNCS withError:reason];
            [conn.bncsSocket disconnect];
            return nil;
        }
    }
}

- (NSData *)createLogonResponseForConnection:(BNCChatConnection *)conn
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
    
    NSMutableData *response = [NSMutableData new];
    [response writeUInt32:conn.clientToken];
    [response writeUInt32:conn.serverToken];
    
    NSMutableData *hashBuffer = [NSMutableData new];
    [hashBuffer writeStringWithoutNullTerminator:[password lowercaseString]];
    [response appendData:[hashBuffer doubleBrokenSha1HashWithClientToken:conn.clientToken
                                                          andServerToken:conn.serverToken]];
    
    [response writeString:username];
    return [response buildBncsPacketWithID:SID_LOGONRESPONSE2];
}

@end
