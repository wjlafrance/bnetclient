#import "BNCPacketSidLogonResponse2.h"

#import "NSData+BrokenSHA1.h"
#import "NSMutableData+PacketBuffer.h"
#import "BNCChatConnection.h"

typedef NS_ENUM(uint32_t, SID_LOGONRESPONSE2_RESPONSECODE) {
    RESPONSE_SUCCESS = 0,
    RESPONSE_ACCOUNTDOESNOTEXIST = 1,
    RESPONSE_INVALIDPASSWORD = 2,
    RESPONSE_ACCOUNTCLOSED = 6
};

@implementation BNCPacketSidLogonResponse2

- (NSString *)name
{
    return @"SID_LOGONRESPONSE2";
}

- (long)identifier
{
    return SID_IDENTIFIER_BASE + SID_LOGONRESPONSE2;
}

- (void)receivedFailureResponse:(NSString *)reason forConnection:(BNCChatConnection *)conn
{
    [conn.delegate battleNetConnection:conn didFailToAuthenticateUserToService:BNCS withError:reason];
    [conn disconnect];
}

- (NSData *)bncsResponseForPacket:(NSMutableData *)packet forBattleNetConnection:(BNCChatConnection *)conn
{
    SID_LOGONRESPONSE2_RESPONSECODE responseCode = [packet readUInt32];
    switch (responseCode) {
        case RESPONSE_SUCCESS:
            [conn.delegate battleNetConnection:conn didAuthenticateUserToService:BNCS];
            return [self buildEnterChatPackets];
            
        case RESPONSE_ACCOUNTDOESNOTEXIST:
            [conn.delegate battleNetConnection:conn didBeginCreatingAccountForService:BNCS];
            return [self buildCreateAccountPacket];
            
        case RESPONSE_INVALIDPASSWORD:
            [self receivedFailureResponse:@"Invalid password." forConnection:conn];
            return nil;
        
        case RESPONSE_ACCOUNTCLOSED: {
            NSString *reason = [NSString stringWithFormat:@"Account closed -- %@", [packet readString]];
            [self receivedFailureResponse:reason forConnection:conn];
            return nil;
        }
        
        default: {
            NSString *reason = [NSString stringWithFormat:@"Server gave an illegal response to SID_LOGONRESPONSE2: 0x%X", responseCode];
            [self receivedFailureResponse:reason forConnection:conn];
            return nil;
        }
    }
}

- (NSData *)buildEnterChatPackets
{
    NSMutableData *response = [NSMutableData new];
    
    NSMutableData *enterchat = [NSMutableData new];
    [enterchat writeString:[NSUserDefaults.standardUserDefaults valueForKey:@"username"]];
    [enterchat writeString:@""];
    [response appendData:[enterchat buildBncsPacketWithID:SID_ENTERCHAT]];
    
    NSMutableData *getchannellist = [NSMutableData new];
    [getchannellist writeUInt32:0];
    [response appendData:[getchannellist buildBncsPacketWithID:SID_GETCHANNELLIST]];
    
    NSMutableData *joinchannel = [NSMutableData new];
    [joinchannel writeUInt32:1]; // First Join flag
    [joinchannel writeString:@"The Void"]; // Ignored for first join
    [response appendData:[joinchannel buildBncsPacketWithID:SID_JOINCHANNEL]];
    
    NSString *homeChannel = [NSUserDefaults.standardUserDefaults valueForKey:@"home_channel"];
    if (homeChannel) {
        NSMutableData *joinchannel2 = [NSMutableData new];
        [joinchannel2 writeUInt32:2]; // Force join
        [joinchannel2 writeString:homeChannel];
        [response appendData:[joinchannel2 buildBncsPacketWithID:SID_JOINCHANNEL]];
    }
    
    return response;
}

- (NSData *)buildCreateAccountPacket
{
    NSMutableData *response = [NSMutableData new];
    
    NSString *username = [NSUserDefaults.standardUserDefaults valueForKey:@"username"];
    NSString *password = [NSUserDefaults.standardUserDefaults valueForKey:@"password"];

    NSMutableData *hashBuffer = [NSMutableData new];
    [hashBuffer writeStringWithoutNullTerminator:[password lowercaseString]];
    [response appendData:[hashBuffer brokenSha1Hash]];
    
    [response writeString:username];
    
    return [response buildBncsPacketWithID:SID_CREATEACCOUNT2];
}

@end
