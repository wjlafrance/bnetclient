#import "BNCConstants.h"

@interface BNCPacket : NSObject

@property (readonly) NSString *name;
@property (readonly) long identifier;

- (NSData *)bnlsResponseForPacket:(NSMutableData *)packet forBattleNetConnection:(BNCChatConnection *)conn;
- (NSData *)bncsResponseForPacket:(NSMutableData *)packet forBattleNetConnection:(BNCChatConnection *)conn;

@end
