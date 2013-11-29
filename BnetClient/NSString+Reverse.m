#import "NSString+Reverse.h"

@implementation NSString (Reverse)

- (NSString *)stringByReversingString
{
    NSMutableString *reverse = [NSMutableString new];
    for (NSInteger index = [self length] - 1; index >= 0; index--) {
        [reverse appendString:[self substringWithRange:NSMakeRange(index, 1)]];
    }
    return reverse;
}

@end
