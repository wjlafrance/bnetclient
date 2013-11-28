#import "BNCPacket.h"

#import "NSMutableData+PacketBuffer.h"

@implementation BNCPacket

- (NSString *)name
{
    [NSException raise:@"Please use a subclass of BNCPacket." format:nil];
    return nil;
}

- (long)identifier
{
    [NSException raise:@"Please use a subclass of BNCPacket." format:nil];
    return 0;
}

- (NSData *)bnlsResponseForPacket:(NSMutableData *)__unused packet
           forBattleNetConnection:(BNCChatConnection *)__unused conn
{
    return nil;
}

- (NSData *)bncsResponseForPacket:(NSMutableData *)__unused packet
           forBattleNetConnection:(BNCChatConnection *)__unused conn
{
    return nil;
}

@end
