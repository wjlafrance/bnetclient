#import "BattleNetProductDiablo2Expansion.h"

@implementation BattleNetProductDiablo2Expansion

- (uint32_t)bncsProductCode
{
    return 'D2XP';
}

- (uint32_t)bnlsProductCode
{
    return 5;
}

- (NSString *)humanReadableString
{
    return @"Diablo II: Lord of Destruction";
}

- (BOOL)requiresExpansionKey
{
    return YES;
}

@end
