#import "BattleNetProductStarCraftExpansion.h"

@implementation BattleNetProductStarCraftExpansion

- (uint32_t)bncsProductCode
{
    return 'SEXP';
}

- (uint32_t)bnlsProductCode
{
    return 2;
}

- (NSString *)humanReadableString
{
    return @"StarCraft: Brood War";
}

- (BOOL)requiresExpansionKey
{
    return YES;
}

@end
