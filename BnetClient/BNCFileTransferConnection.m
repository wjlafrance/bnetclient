#import "BNCFileTransferConnection.h"

#import "NSMutableData+PacketBuffer.h"

#define BNFTP_HEADER_LENGTH_TAG 1
#define BNFTP_HEADER_TAG 2
#define BNFTP_DATA_TAG 3

@interface BNCFileTransferConnection ()

@property (strong) AsyncSocket *bncsSocket;

@end


@implementation BNCFileTransferConnection

- (void)downloadFile:(NSString *)file toPath:(NSString *)path
{
    self.bncsSocket = [[AsyncSocket alloc] initWithDelegate:self];
    self.filename = file;
    self.path = path;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bncsServer = [defaults valueForKey:@"bncs_server"];
    
    NSError *err;
    if (![self.bncsSocket connectToHost:bncsServer onPort:6112 error:&err]) {
        [self.delegate bnftp:self didFailWithError:err];
    }
}

- (void)onSocket:(AsyncSocket *)__unused sock willDisconnectWithError:(NSError *)err
{
    if (err) {
        [self.delegate bnftp:self didFailWithError:err];
    }
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)__unused host port:(UInt16)__unused port
{
    NSMutableData *protocolByte = [NSMutableData new];
    [protocolByte writeUInt8:0x02];
    [sock writeData:protocolByte withTimeout:-1 tag:0];
    
    NSMutableData *request = [NSMutableData new];
    [request writeUInt32:'IX86'];
    [request writeUInt32:'D2DV'];
    [request writeUInt32:0]; // Banner ID
    [request writeUInt32:0]; // Banner file extension
    [request writeUInt32:0]; // File start position
    [request writeUInt64:0]; // Local filetime
    [request writeString:self.filename];
    [sock writeData:[request buildBnftpPacket] withTimeout:-1 tag:0];
    
    [sock readDataToLength:2 withTimeout:-1 tag:BNFTP_HEADER_LENGTH_TAG];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSMutableData *buffer = [data mutableCopy];
    switch (tag) {
        case BNFTP_HEADER_LENGTH_TAG: {
            uint16_t length = [buffer readUInt16];
            [sock readDataToLength:length - 2 withTimeout:-1 tag:BNFTP_HEADER_TAG];
            break;
        }
        case BNFTP_HEADER_TAG:
            [buffer readUInt16]; // padding
            uint32_t filesize = [buffer readUInt32];
            [sock readDataToLength:filesize withTimeout:-1 tag:BNFTP_DATA_TAG];
            break;
        case BNFTP_DATA_TAG: {
            NSError *err;
            if ([data writeToFile:self.path options:NSDataWritingAtomic error:&err]) {
                [self.delegate bnftp:self didFinishDownload:self.path];
            } else {
                [self.delegate bnftp:self didFailWithError:err];
            }
            break;
        }
    }
}

@end
