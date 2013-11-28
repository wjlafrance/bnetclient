#import "BattleNetProductWarCraft3Expansion.h"

@implementation BattleNetProductWarCraft3Expansion

- (uint32_t)bncsProductCode
{
    return 'W3XP';
}

- (uint32_t)bnlsProductCode
{
    return 8;
}

- (NSString *)humanReadableString
{
    return @"WarCraft III: The Frozen Throne";
}

- (BOOL)requiresExpansionKey
{
    return YES;
}

@end
