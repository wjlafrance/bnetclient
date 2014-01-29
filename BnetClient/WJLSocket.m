#import "WJLSocket.h"
#import "NSData+DebugOutput.h"
#import <netdb.h>

@interface WJLSocket ()

@property (strong) dispatch_queue_t socketQueue;
@property (copy)   NSString *hostname;
@property (assign) NSUInteger port;
@property (assign) int socketDescriptor;
@property (assign) int state;

@end

@implementation WJLSocket

+ (instancetype)socketWithHostname:(NSString *)hostname port:(NSUInteger)port
{
    return [[self alloc] initWithHostname:hostname port:port];
}

- (instancetype)initWithHostname:(NSString *)hostname port:(NSUInteger)port
{
    self = [super init];
    if (self) {
        _socketQueue = dispatch_queue_create("net.wjlafrance.socketqueue", DISPATCH_QUEUE_CONCURRENT);
        _hostname = hostname;
        _port = port;
    }
    return self;
}

- (void)dealloc
{
    [self close];
}

- (void)close
{
    close(self.socketDescriptor);
    self.socketDescriptor = 0;
    self.state = 0;
}

- (void)connect:(void(^)(BOOL success))handler
{
    NSAssert(NULL != handler, @"Handler must not be NULL");

    NSAssert(0 == self.state, @"-connect may only be called once.");
    self.state = 1;

    self.socketDescriptor = socket(AF_INET, SOCK_STREAM, 0);
    NSAssert(0 != self.socketDescriptor, @"Socket allocation failed!");

    dispatch_async(_socketQueue, ^{
        struct hostent *host = gethostbyname([self.hostname UTF8String]);
        struct sockaddr_in sockaddr;
        memset(&sockaddr, 0, sizeof(sockaddr));
        sockaddr.sin_len = sizeof(sockaddr);
        sockaddr.sin_family = AF_INET;
        sockaddr.sin_port = htons(self.port);
        sockaddr.sin_addr = *(struct in_addr *) host->h_addr_list[0];

        BOOL success = (-1 != connect(self.socketDescriptor, (struct sockaddr *) &sockaddr, sizeof(sockaddr)));
        if (success) {
            self.state = 2;
        } else {
            [self close];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(success);
        });
    });
}

- (void)write:(NSData *)data withHandler:(void(^)(BOOL success))handler
{
    NSAssert(nil != data, @"data must not be nil");

    NSAssert(2 == self.state, @"Socket must be connected before calling -write");

    dispatch_async(_socketQueue, ^{
        if (self.debug) {
            NSLog(@"C -> S %@:%lu (%ld bytes) %@", self.hostname, (unsigned long) self.port, (unsigned long) [data length], [data debugOutput]);
        }

        ssize_t bytesWritten = send(self.socketDescriptor, [data bytes], [data length], 0);

        BOOL success = (bytesWritten == (ssize_t) [data length]);
        if (!success) {
            [self close];
        }

        if (NULL != handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(success);
            });
        }
    });
}

- (void)readWithLength:(NSUInteger)length flags:(int)flags withHandler:(void(^)(NSData *data))handler
{
    NSAssert(NULL != handler, @"Handler must not be NULL");

    NSAssert(2 == self.state, @"Socket must be connected before calling -receiveWithMaxLength:withHandler:");

    dispatch_async(_socketQueue, ^{
        void *buffer = malloc(length);
        NSData *data;

        ssize_t bytesRead = recv(self.socketDescriptor, buffer, length, flags);

        BOOL success = (bytesRead == (ssize_t) length);
        if (!success) {
            [self close];
        } else {
            data = [NSData dataWithBytes:buffer length:bytesRead];
        }

        free(buffer);

        if (success && self.debug && !(flags & MSG_PEEK)) {
            NSLog(@"S -> C %@:%lu (%ld bytes) %@", self.hostname, (unsigned long) self.port, (unsigned long) [data length], [data debugOutput]);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            handler(data);
        });
    });
}

- (void)readWithLength:(NSUInteger)length withHandler:(void(^)(NSData *data))handler
{
    [self readWithLength:length flags:MSG_WAITALL withHandler:handler];
}

- (void)peekWithLength:(NSUInteger)length withHandler:(void(^)(NSData *data))handler
{
    [self readWithLength:length flags:MSG_PEEK | MSG_WAITALL withHandler:handler];
}

@end
