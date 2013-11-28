@interface BattleNetProduct : NSObject

+ (NSArray *)allProducts ATTR_CONST;

+ (instancetype)currentProduct ATTR_PURE;

@property (readonly) uint32_t  bncsProductCode;
@property (readonly) uint32_t  bnlsProductCode;
@property (readonly) NSString *humanReadableString;
@property (readonly) BOOL      requiresKey;
@property (readonly) BOOL      requiresExpansionKey;

@end
