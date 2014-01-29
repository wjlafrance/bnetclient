#import "NSData+DebugOutput.h"

@implementation NSData (DebugOutput)

- (NSString *)debugOutput
{
    int rowlength = 16;
    const uint8_t *data = [self bytes];
    NSMutableString *str = [NSMutableString new];
    for (NSInteger i = 0; i < (NSInteger) [self length]; ) {
        [str appendFormat:@"\n"];
        for (NSInteger j = 0; j < rowlength; j++, i++) {
            if (i >= (NSInteger) [self length] || i < 0) {
                [str appendString:@"  "];
            } else {
                [str appendFormat:@"%02x", data[i]];
            }
            if (i % 2) [str appendString:@" "];
        }
        i -= rowlength;
        [str appendString:@" "];
        for (NSInteger j = 0; j < rowlength; j++, i++) {
            if (i >= (NSInteger) [self length] || i < 0) {
                [str appendString:@" "];
            } else if (data[i] < 33 || data[i] > '~') {
                [str appendString:@"."];
            } else {
                [str appendFormat:@"%c", data[i]];
            }
        }
    }
    return str;
}

@end
