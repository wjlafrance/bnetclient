#import "BNCChatConnection.h"

#import "NSMutableData+PacketBuffer.h"
#import "BNCPacketManager.h"
#import "BattleNetProduct.h"
#import "BNCPacketSidAuthInfo.h"
#import "BNCPacketBnlsRequestVersionByte.h"

@interface BNCChatConnection () <AsyncSocketDelegate>

@property (strong) AsyncSocket *bnlsSocket;
@property (strong) AsyncSocket *bncsSocket;

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
        _bnlsSocket = [[AsyncSocket alloc] initWithDelegate:self];
        _bncsSocket = [[AsyncSocket alloc] initWithDelegate:self];
        
        if ([self checkSettingsValidity]) {
            [self connectBnls];
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
    NSError *err;
    if (![self.bnlsSocket connectToHost:server onPort:9367 error:&err]) {
        [self.delegate battleNetConnection:self
                  didDisconnectFromService:BNLS
                                 withError:[err description]];
    }

}

- (void)connectBncs
{
    NSString *server = [[NSUserDefaults standardUserDefaults] valueForKey:@"bncs_server"];
    NSError *err;
    if (![self.bncsSocket connectToHost:server onPort:6112 error:&err]) {
        [self.delegate battleNetConnection:self
                  didDisconnectFromService:BNCS
                                 withError:[err description]];
    }
}


#pragma mark - AsyncSocketDelegate

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    [self.delegate battleNetConnection:self
              didDisconnectFromService:(sock == self.bncsSocket ? BNCS : BNLS)
                             withError:[err description]];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    [self.delegate battleNetConnection:self
              didDisconnectFromService:(sock == self.bncsSocket ? BNCS : BNLS)
                             withError:nil];
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
    [self.delegate battleNetConnection:self
           didBeginConnectingToService:(sock == self.bncsSocket ? BNCS : BNLS)];
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)__unused host port:(UInt16)__unused port
{
    [self.delegate battleNetConnection:self
                   didConnectToService:(sock == self.bncsSocket ? BNCS : BNLS)];
    
    if (sock == self.bnlsSocket) {
        [sock readDataToLength:3 withTimeout:-1 tag:-1];
        [self connectBncs];
    } else {
        [sock readDataToLength:4 withTimeout:-1 tag:-1];
        
        NSMutableData *protocolByte = [NSMutableData new];
        [protocolByte writeUInt8:1];
        [self sendBncsPacket:protocolByte];
        [self.delegate battleNetConnection:self didBeginAuthenticatingClientToService:BNCS];
        [self sendBnlsPacket:[[BNCPacketBnlsRequestVersionByte new] packet]];
    }
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSMutableData *packet = [data mutableCopy];
    if (tag == -1) { // Received packet header -- read remainder of packet and tag with packet ID
        if (sock == self.bnlsSocket) {
            uint16_t length = [packet readUInt16];
            uint8_t packetId = [packet readUInt8];
            [sock readDataToLength:length - 3 withTimeout:-1 tag:BNLS_IDENTIFIER_BASE + packetId];
            [sock readDataToLength:3 withTimeout:-1 tag:-1];
        } else {
            [packet readUInt8]; // skip sanity byte
            uint8_t packetId = [packet readUInt8];
            uint16_t length = [packet readUInt16];
            [sock readDataToLength:length - 4 withTimeout:-1 tag:SID_IDENTIFIER_BASE + packetId];
            [sock readDataToLength:4 withTimeout:-1 tag:-1];
            
            LogMessageCompat(@"Received BNCS packet header %@",
                             [[BNCPacketManager packetHandlerForIdentifier:SID_IDENTIFIER_BASE + packetId] name]);
        }
    } else { // Received remainder of packet
        BNCPacket *handler = [BNCPacketManager packetHandlerForIdentifier:tag];
        LogMessageCompat(@"Received BNCS packet body %@:\n%@", [handler name], packet);
        if (handler) {
            [self sendBncsPacket:[handler bncsResponseForPacket:packet forBattleNetConnection:self]];
            [self sendBnlsPacket:[handler bnlsResponseForPacket:packet forBattleNetConnection:self]];
        } else {
            [self debug:[NSString stringWithFormat:@"No handler for 0x%02X.", (int) tag]];
            [self debug:[NSString stringWithFormat:@"Data for 0x%02X: %@", (int) tag, data]];
        }
    }
}


#pragma mark - Packet sending

- (void)sendBncsPacket:(NSData *)data
{
    if (data) {
        [self.bncsSocket writeData:data withTimeout:-1 tag:0];
        LogMessageCompat(@"Sending BNCS packet: %@", data);
    }
}

- (void)sendBnlsPacket:(NSData *)data
{
    if (data) {
        [self.bnlsSocket writeData:data withTimeout:-1 tag:0];
        LogMessageCompat(@"Sending BNLS packet: %@", data);
    }
}


#pragma mark - Debug logging

- (void)debug:(NSString *)string
{
    LogMessageCompat(@"BNET DEBUG -- %@", string);
    [self.delegate battleNetConnection:self outputDebugString:string];
}


#pragma mark - Sending text

- (void)sendText:(NSString *)string
{
    LogMessageCompat(@"SID_CHATCOMMAND: %@", string);
    NSMutableData *chatcommand = [NSMutableData new];
    [chatcommand writeString:string];
    [self sendBncsPacket:[chatcommand buildBncsPacketWithID:SID_CHATCOMMAND]];
    
    if (![string hasPrefix:@"/"]) {
        [self.delegate battleNetConnection:self eventDidOccur:EID_TALK username:self.username text:string flags:0 ping:0];
    }
}

@end
