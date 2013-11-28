#import "NSData+BrokenSHA1.h"

#import "NSMutableData+PacketBuffer.h"
#import "xsha1.h"

@implementation NSData (BrokenSHA1)

- (NSData *)brokenSha1Hash
{
    uint32_t result[5];
    void *bytes = malloc(self.length);
    [self getBytes:bytes];
    xsha1_calcHashBuf(bytes, self.length, (uint32_t *)result);
    free(bytes);
    return [NSData dataWithBytes:&result length:sizeof(uint32_t) * 5];
}

- (NSData *)doubleBrokenSha1HashWithClientToken:(uint32_t)clientToken andServerToken:(uint32_t)serverToken
{
    NSMutableData *doubleHashBuffer = [NSMutableData new];
    [doubleHashBuffer writeUInt32:clientToken];
    [doubleHashBuffer writeUInt32:serverToken];
    [doubleHashBuffer appendData:[self brokenSha1Hash]];
    return [doubleHashBuffer brokenSha1Hash];
}

@end
