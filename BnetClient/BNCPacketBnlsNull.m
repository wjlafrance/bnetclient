#import "BNCPacketBnlsNull.h"

@implementation BNCPacketBnlsNull

- (NSString *)name
{
    return @"BNLS_NULL";
}

- (long)identifier
{
    return BNLS_IDENTIFIER_BASE + BNLS_NULL;
}

@end
