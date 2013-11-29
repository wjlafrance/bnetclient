#import "BNCChannelModel.h"


#pragma mark - BNCChannelUser

@interface BNCChannelUser : NSObject

@property (copy) NSString *name;
@property (copy) NSString *client;
@property (assign) uint32_t flags;

@end

@implementation BNCChannelUser

+ (instancetype)userWithName:(NSString *)name client:(NSString *)client flags:(uint32_t)flags
{
    return [[self alloc] initWithName:name client:client flags:flags];
}

- (instancetype)initWithName:(NSString *)name client:(NSString *)client flags:(uint32_t)flags
{
    self = [super init];
    if (self) {
        _name = name;
        _client = client;
        _flags = flags;
    }
    return self;
}

- (BOOL)isEqual:(BNCChannelUser *)object
{
    return [self.name isEqualToString:object.name];
}

@end

#pragma mark - BNCChannelModel

@interface BNCChannelModel ()

@property (readwrite, copy) NSString *name;

@property (strong) NSMutableArray *users;

@end


@implementation BNCChannelModel

+ (instancetype)channelWithName:(NSString *)name
{
    return [[self alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
        _users = [NSMutableArray array];
    }
    return self;
}

- (void)addUserWithName:(NSString *)name client:(NSString *)client flags:(uint32_t)flags
{
    [self.users addObject:[BNCChannelUser userWithName:name client:(NSString *)client flags:flags]];
}

- (void)removeUser:(NSString *)name
{
    [self.users removeObject:[BNCChannelUser userWithName:name client:nil flags:0]];
}

- (NSUInteger)numberOfUsers ATTR_PURE
{
    return [self.users count];
}

- (NSString *)userAtIndex:(NSUInteger)index ATTR_PURE
{
    return [self.users[index] name];
}

- (NSString *)clientForUserAtIndex:(NSUInteger)index ATTR_PURE
{
    BNCChannelUser *user = self.users[index];
    return user.client;
}

- (uint32_t)flagsForUserAtIndex:(NSUInteger)index ATTR_PURE
{
    BNCChannelUser *user = self.users[index];
    return user.flags;
}

@end
