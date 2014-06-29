#import "BNCChatConnection.h"

#import "NSMutableData+PacketBuffer.h"
#import "BNCPacketManager.h"
#import "BattleNetProduct.h"
#import "BNCPacketSidAuthInfo.h"
#import "BNCPacketBnlsRequestVersionByte.h"
#import "WJLSocket.h"

@interface BNCChatConnection ()

@property (strong) WJLSocket *bnlsSocket;
@property (strong) WJLSocket *bncsSocket;

@property (readwrite, copy)   NSString *username;

@property (readwrite, assign) uint32_t  mpqFiletime;
@property (readwrite, copy)   NSString *mpqFilename;
@property (readwrite, copy)   NSString *mpqFormula;

@property (readwrite, assign) uint32_t  loginType;
@property (readwrite, assign) uint32_t  serverToken;
@property (readwrite, assign) uint32_t  clientToken;
@property (readwrite, copy)   NSData   *hashedKey;

@end


@implementation BNCChatConnection

- (instancetype)initWithDelegate:(id<BNCChatConnectionDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;

        if ([self checkSettingsValidity]) {
//            [self connectBnls];
        }
    }
    return self;
}


#pragma mark - Connect

- (BOOL)checkSettingsValidity
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL valid = YES;
    
    if (![defaults valueForKey:@"bnls_server"]) {
        [self.delegate battleNetConnection:self
                  didDisconnectFromService:BNCS
                                 withError:@"A BNLS server must be specified in the Settings app."];
        valid = NO;
    }
    
    if (![defaults valueForKey:@"bncs_server"]) {
        [self.delegate battleNetConnection:self
                  didDisconnectFromService:BNCS
                                 withError:@"A Battle.net server must be specified in the Settings app."];
        valid = NO;
    }
    
    if (![defaults valueForKey:@"bnls_server"]) {
        [self.delegate battleNetConnection:self
                  didDisconnectFromService:BNCS
                                 withError:@"A BNLS server must be specified in the Settings app."];
        valid = NO;
    }
    
    if (BattleNetProduct.currentProduct.requiresKey && ![defaults valueForKey:@"cdkey"]) {
        [self.delegate battleNetConnection:self
                  didDisconnectFromService:BNCS
                                 withError:@"A CD-Key must be specified in the Settings app."];
        valid = NO;
    }
    
    if (BattleNetProduct.currentProduct.requiresExpansionKey && ![defaults valueForKey:@"cdkey"]) {
        [self.delegate battleNetConnection:self
                  didDisconnectFromService:BNCS
                                 withError:@"An expansion CD-Key must be specified in the Settings app."];
        valid = NO;
    }
    
    if (![defaults valueForKey:@"username"]) {
        [self.delegate battleNetConnection:self
                  didDisconnectFromService:BNCS
                                 withError:@"A username must be specified in the Settings app."];
        valid = NO;
    }
    
    if (![defaults valueForKey:@"password"]) {
        [self.delegate battleNetConnection:self
                  didDisconnectFromService:BNCS
                                 withError:@"A password must be specified in the Settings app."];
        valid = NO;
    }
    
    return valid;
}

- (void)connectBnls
{
    NSString *server = [[NSUserDefaults standardUserDefaults] valueForKey:@"bnls_server"];
    self.bnlsSocket = [WJLSocket socketWithHostname:server port:9367];
    self.bnlsSocket.debug = YES;
    [self.bnlsSocket connect:^(BOOL success) {
        if (success) {
            [self.delegate battleNetConnection:self didConnectToService:BNLS];

            [self connectBncs];

            [self doBnlsReadLoop];
        } else {
            [self.delegate battleNetConnection:self
                      didDisconnectFromService:BNLS
                                     withError:nil];
        }
    }];

    [self.delegate battleNetConnection:self didBeginConnectingToService:BNLS];
}

- (void)connectBncs
{
    NSString *server = [[NSUserDefaults standardUserDefaults] valueForKey:@"bncs_server"];
    self.bncsSocket = [WJLSocket socketWithHostname:server port:6112];
    self.bncsSocket.debug = YES;
    [self.bncsSocket connect:^(BOOL success) {
        if (success) {
            [self.delegate battleNetConnection:self didConnectToService:BNCS];

            NSMutableData *protocolByte = [NSMutableData new];
            [protocolByte writeUInt8:1];
            [self sendBncsPacket:protocolByte];

            [self.delegate battleNetConnection:self didBeginAuthenticatingClientToService:BNCS];
            [self sendBnlsPacket:[[BNCPacketBnlsRequestVersionByte new] packet]];

            [self doBncsReadLoop];
        } else {
            [self.delegate battleNetConnection:self
                      didDisconnectFromService:BNCS
                                     withError:nil];
        }
    }];

   [self.delegate battleNetConnection:self didBeginConnectingToService:BNCS];
}

- (void)disconnect
{
    self.bnlsSocket = nil;
    [self.delegate battleNetConnection:self didDisconnectFromService:BNLS withError:nil];
    self.bncsSocket = nil;
    [self.delegate battleNetConnection:self didDisconnectFromService:BNCS withError:nil];
}

- (void)doBnlsReadLoop
{
    [self.bnlsSocket readWithLength:3 withHandler:^(NSData *data) {
        [self onSocket:self.bnlsSocket didReadPacketHeader:data];
    }];
}

- (void)doBncsReadLoop
{
    [self.bncsSocket readWithLength:4 withHandler:^(NSData *data) {
        [self onSocket:self.bncsSocket didReadPacketHeader:data];
    }];
}

- (void)onSocket:(WJLSocket *)sock didReadPacketHeader:(NSData *)data
{
    void (^handlePacket)(int, NSData *) = ^(int tag, NSData *data) {
        BNCPacket *handler = [BNCPacketManager packetHandlerForIdentifier:tag];
        NSLog(@"Received packet %@", [handler name]);

        NSMutableData *buffer = [data mutableCopy];
        if (handler) {
            [self sendBncsPacket:[handler bncsResponseForPacket:buffer forBattleNetConnection:self]];
            [self sendBnlsPacket:[handler bnlsResponseForPacket:buffer forBattleNetConnection:self]];
        } else {
            [self debug:[NSString stringWithFormat:@"No handler for 0x%02X.", (int) tag]];
            [self debug:[NSString stringWithFormat:@"Data for 0x%02X: %@", (int) tag, data]];
        }
    };

    if (!data) {
        [self.delegate battleNetConnection:self didDisconnectFromService:(sock == self.bncsSocket ? BNCS : BNLS) withError:nil];
        return;
    }

    NSMutableData *packet = [data mutableCopy];
    if (sock == self.bnlsSocket) {
        uint16_t length = [packet readUInt16];
        uint8_t packetId = [packet readUInt8];
        [sock readWithLength:length - 3 withHandler:^(NSData *data) {
            handlePacket(BNLS_IDENTIFIER_BASE + packetId, data);
            [self doBnlsReadLoop];
        }];
    } else {
        [packet readUInt8]; // skip sanity byte
        uint8_t packetId = [packet readUInt8];
        uint16_t length = [packet readUInt16];
        [sock readWithLength:length - 4 withHandler:^(NSData *data) {
            handlePacket(SID_IDENTIFIER_BASE + packetId, data);
            [self doBncsReadLoop];
        }];

    }
}


#pragma mark - Packet sending

- (void)sendBncsPacket:(NSData *)data
{
    if (data) {
        [self.bncsSocket write:data withHandler:^(BOOL __unused success) {
            NSLog(@"Sent BNCS packet: %@", data);
        }];
    }
}

- (void)sendBnlsPacket:(NSData *)data
{
    if (data) {
        [self.bnlsSocket write:data withHandler:^(BOOL __unused success) {
            NSLog(@"Sent BNLS packet: %@", data);
        }];
    }
}


#pragma mark - Debug logging

- (void)debug:(NSString *)string
{
    NSLog(@"BNET DEBUG -- %@", string);
    [self.delegate battleNetConnection:self outputDebugString:string];
}


#pragma mark - Sending text

- (void)sendText:(NSString *)string
{
    NSLog(@"SID_CHATCOMMAND: %@", string);
    NSMutableData *chatcommand = [NSMutableData new];
    [chatcommand writeString:string];
    [self sendBncsPacket:[chatcommand buildBncsPacketWithID:SID_CHATCOMMAND]];
    
    if (![string hasPrefix:@"/"]) {
        [self.delegate battleNetConnection:self eventDidOccur:EID_TALK username:self.username text:string flags:0 ping:0];
    }
}

@end
