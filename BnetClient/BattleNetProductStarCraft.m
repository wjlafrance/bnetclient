#import "BattleNetProductStarCraft.h"

@implementation BattleNetProductStarCraft

- (uint32_t)bncsProductCode
{
    return 'STAR';
}

- (uint32_t)bnlsProductCode
{
    return 1;
}

- (NSString *)humanReadableString
{
    return @"StarCraft";
}

@end
