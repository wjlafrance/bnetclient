#import "BattleNetProductWarCraft3.h"

@implementation BattleNetProductWarCraft3

- (uint32_t)bncsProductCode
{
    return 'WAR3';
}

- (uint32_t)bnlsProductCode
{
    return 7;
}

- (NSString *)humanReadableString
{
    return @"WarCraft III: Reign of Chaos";
}

@end
