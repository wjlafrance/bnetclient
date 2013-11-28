#import "BattleNetProduct.h"

#import "WJLRuntimeUtils.h"

@implementation BattleNetProduct

+ (NSArray *)allProducts ATTR_CONST
{
    static NSArray *allProducts;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *_allProducts = [NSMutableArray new];
        NSArray *productClassNames = [WJLRuntimeUtils namesOfClassesDirectlySubclassingClass:[BattleNetProduct class]];
        for (NSString *className in productClassNames) {
            [_allProducts addObject:[NSClassFromString(className) new]];
        }
        allProducts = [_allProducts copy];
    });
    return allProducts;
}

+ (instancetype)currentProduct ATTR_PURE
{
    NSString *productIdentifier = [[NSUserDefaults standardUserDefaults] valueForKey:@"product"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.plistIdentifier LIKE %@", productIdentifier];
    return [[[self allProducts] filteredArrayUsingPredicate:predicate] firstObject];
}

- (NSString *)plistIdentifier
{
    return [NSString stringWithFormat:@"%c%c%c%c",
            self.bncsProductCode >> 24,
            self.bncsProductCode >> 16,
            self.bncsProductCode >> 8,
            self.bncsProductCode];
}

- (uint32_t)bncsProductCode
{
    [NSException raise:@"Please use [BattleNetProduct currentProduct]." format:@""];
    return 0;
}

- (uint32_t)bnlsProductCode
{
    [NSException raise:@"Please use [BattleNetProduct currentProduct]." format:@""];
    return 0;
}

- (NSString *)humanReadableString
{
    [NSException raise:@"Please use [BattleNetProduct currentProduct]." format:@""];
    return @"";
}

- (BOOL)requiresKey
{
    return YES;
}

- (BOOL)requiresExpansionKey
{
    return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"BattleNetProduct: %@", self.humanReadableString];
}

@end
