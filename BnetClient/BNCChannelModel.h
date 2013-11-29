@interface BNCChannelModel : NSObject

+ (instancetype)channelWithName:(NSString *)name;

@property (readonly, copy) NSString *name;

- (void)addUserWithName:(NSString *)name client:(NSString *)client flags:(uint32_t)flags;

- (void)removeUser:(NSString *)name;

- (NSUInteger)numberOfUsers ATTR_PURE;

- (NSString *)userAtIndex:(NSUInteger)index ATTR_PURE;

- (NSString *)clientForUserAtIndex:(NSUInteger)index ATTR_PURE;

- (uint32_t)flagsForUserAtIndex:(NSUInteger)index ATTR_PURE;

@end
