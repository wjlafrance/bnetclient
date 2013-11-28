#import "BattleNetProductWarCraft2.h"

@implementation BattleNetProductWarCraft2

- (uint32_t)bncsProductCode
{
    return 'W2BN';
}

- (uint32_t)bnlsProductCode
{
    return 3;
}

- (NSString *)humanReadableString
{
    return @"WarCraft II: Battle.net Edition";
}

@end
