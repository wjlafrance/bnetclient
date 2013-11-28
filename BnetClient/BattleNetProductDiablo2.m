#import "BattleNetProductDiablo2.h"

@implementation BattleNetProductDiablo2

- (uint32_t)bncsProductCode
{
    return 'D2DV';
}

- (uint32_t)bnlsProductCode
{
    return 4;
}

- (NSString *)humanReadableString
{
    return @"Diablo II";
}

@end
