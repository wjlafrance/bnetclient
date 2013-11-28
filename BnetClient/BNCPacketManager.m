#import "BNCPacketManager.h"

#import "WJLRuntimeUtils.h"
#import "BNCPacket.h"

@implementation BNCPacketManager

+ (NSArray *)allPacketHandlers ATTR_CONST
{
    static NSArray *allPacketHandlers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *_allPacketHandlers = [NSMutableArray new];
        NSArray *packetHandlerClassNames = [WJLRuntimeUtils namesOfClassesDirectlySubclassingClass:[BNCPacket class]];
        for (NSString *className in packetHandlerClassNames) {
            [_allPacketHandlers addObject:[NSClassFromString(className) new]];
        }
        allPacketHandlers = [_allPacketHandlers copy];
    });
    return allPacketHandlers;
}

+ (BNCPacket *)packetHandlerForIdentifier:(long)identifier ATTR_CONST
{
    for (BNCPacket *handler in [self allPacketHandlers]) {
        if (identifier == handler.identifier) {
            return handler;
        }
    }
    return nil;
}

@end
