#import "BNCFileTransferConnection.h"
#import "NSMutableData+PacketBuffer.h"
#import "WJLSocket.h"

@interface BNCFileTransferConnection ()

@property (strong) WJLSocket *bncsSocket;

@end


@implementation BNCFileTransferConnection

- (void)downloadFile:(NSString *)file toPath:(NSString *)path
{
    self.filename = file;
    self.path = path;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bncsServer = [defaults valueForKey:@"bncs_server"];

    if (!bncsServer || 0 == bncsServer.length) {
        [self.delegate bnftp:self didFailWithError:[NSError errorWithDomain:@"BNFTP" code:0 userInfo:@{@"reason": @"BNCS address is not configured."}]];
        return;
    }

    self.bncsSocket = [WJLSocket socketWithHostname:bncsServer port:6112];
    self.bncsSocket.debug = YES;
    [self.bncsSocket connect:^(BOOL success) {
        if (!success) {
            [self.delegate bnftp:self didFailWithError:[NSError errorWithDomain:@"BNFTP" code:0 userInfo:@{@"reason": @"Unable to open connection to BNCS / BNFTP."}]];
        } else {
            NSMutableData *protocolByte = [NSMutableData new];
            [protocolByte writeUInt8:0x02];
            [self.bncsSocket write:protocolByte withHandler:^(BOOL success) {
                if (!success) {
                    [self.delegate bnftp:self didFailWithError:[NSError errorWithDomain:@"BNFTP" code:0 userInfo:@{@"reason": @"Failed to write protocol byte to BNFTP."}]];
                } else {
                    NSMutableData *request = [NSMutableData new];
                    [request writeUInt32:'IX86'];
                    [request writeUInt32:'D2DV'];
                    [request writeUInt32:0]; // Banner ID
                    [request writeUInt32:0]; // Banner file extension
                    [request writeUInt32:0]; // File start position
                    [request writeUInt64:0]; // Local filetime
                    [request writeString:self.filename];
                    [self.bncsSocket write:[request buildBnftpPacket] withHandler:^(BOOL success) {
                        if (!success) {
                            [self.delegate bnftp:self didFailWithError:[NSError errorWithDomain:@"BNFTP" code:0 userInfo:@{@"reason": @"Failed to write file request to BNFTP."}]];
                        } else {
                            [self readResponse];
                        }
                    }];
                }
            }];
        }
    }];
}

- (void)readResponse
{
    [self.bncsSocket peekWithLength:2 withHandler:^(NSData *data) {
        if (!data) {
            [self.delegate bnftp:self didFailWithError:nil];
        } else {
            uint16_t headerLength = [[data mutableCopy] readUInt16];
            [self.bncsSocket readWithLength:headerLength withHandler:^(NSData *data) {
                if (!data) {
                    [self.delegate bnftp:self didFailWithError:nil];
                } else {
                    NSMutableData *buffer = [data mutableCopy];
                    [buffer readUInt16]; // header length
                    [buffer readUInt16]; // padding
                    uint32_t filesize = [buffer readUInt32];
                    [self.bncsSocket readWithLength:filesize withHandler:^(NSData *data) {
                        if (!data) {
                            [self.delegate bnftp:self didFailWithError:nil];
                        } else {
                            NSError *err;
                            if ([data writeToFile:self.path options:NSDataWritingAtomic error:&err]) {
                                [self.delegate bnftp:self didFinishDownload:self.path];
                            } else {
                                [self.delegate bnftp:self didFailWithError:err];
                            }
                        }
                    }];
                }
            }];
        }
    }];
}

@end
