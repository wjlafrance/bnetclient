#import <Foundation/Foundation.h>

/**
 * A simple Objective-C wrapper around BSD Sockets for OS X. I haven't tested
 * this on iOS.
 */
@interface WJLSocket : NSObject

@property (assign) BOOL debug;

+ (instancetype)socketWithHostname:(NSString *)hostname port:(NSUInteger)port;

/**
 * Connect to the hostname and port specified in the constructor. The handler is
 * not called until the entire connection process is complete. Once the handler
 is called (indicating success), the socket is ready to be used.
 */
- (void)connect:(void(^)(BOOL success))handler;

/**
 * Write <i>data</i> to the socket.
 *
 * The handler being called with <i>success == YES</i> indicates that the entire
 * buffer was written successfully. Otherwise, <i>success</i> will be <i>NO</i>
 * and the socket will be closed.
 */
- (void)write:(NSData *)data withHandler:(void(^)(BOOL success))handler;

/**
 * Attempt to read up to <i>length</i> bytes from the socket.
 *
 * If the read is successful, the data that was read will be passed to the
 * handler. If the read times out, the handler will be called with a non-nil,
 * zero-length <i>data</i>. A nil <i>data</i> indicates a socket error, and the
 * socket will be closed.
 */
- (void)readWithLength:(NSUInteger)length withHandler:(void(^)(NSData *data))handler;


/**
 * Attempt to peek at up to <i>length</i> bytes from the socket. This data is
 * not removed and will be included in the next read call.
 *
 * If the peek is successful, the data that was peeked will be passed to the
 * handler. If the read times out, the handler will be called with a non-nil,
 * zero-length <i>data</i>. A nil <i>data</i> indicates a socket error, and the
 * socket will be closed.
 */
- (void)peekWithLength:(NSUInteger)length withHandler:(void(^)(NSData *data))handler;

@end
