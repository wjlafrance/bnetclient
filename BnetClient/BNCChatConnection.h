#import "BNCChatConnectionDelegate.h"

@interface BNCChatConnection : NSObject

@property (weak) id<BNCChatConnectionDelegate> delegate;

@property (strong, readonly) AsyncSocket *bnlsSocket;
@property (strong, readonly) AsyncSocket *bncsSocket;

@property (readonly, copy)   NSString    *username;

@property (readonly, assign) uint32_t     mpqFiletime;
@property (readonly, copy)   NSString    *mpqFilename;
@property (readonly, copy)   NSString    *mpqFormula;

@property (readonly, assign) uint32_t     loginType;
@property (readonly, assign) uint32_t     serverToken;
@property (readonly, assign) uint32_t     clientToken;
@property (readonly, copy)   NSData      *hashedKey;

- (instancetype)initWithDelegate:(id<BNCChatConnectionDelegate>)delegate;

- (void)sendText:(NSString *)string;

@end
