#import "BNCConstants.h"

@interface BNCPacketManager : NSObject

+ (BNCPacket *)packetHandlerForIdentifier:(long)identifier ATTR_CONST;

@end
