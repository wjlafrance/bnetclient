#import "BNCIconsBni.h"

#import "NSMutableData+PacketBuffer.h"
#import "UIImage+TargaData.h"

@implementation BNCIconsBni

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSMutableData *data = [[NSData dataWithContentsOfFile:
            [NSTemporaryDirectory() stringByAppendingPathComponent:@"icons.bni"]] mutableCopy];
        
        [data readUInt32]; // Header size
        [data readUInt16]; // BNI Version
        [data readUInt16]; // Alignment
        uint32_t nIcons = [data readUInt32];
        [data readUInt32]; // Data Offset
        
        for (uint i = 0; i < nIcons; i++) {
            uint32_t flags = [data readUInt32];
            CGSize size = CGSizeMake([data readUInt32], [data readUInt32]);
            LogMessageCompat(@"Icon with flags 0x%08X, size %@", flags, NSStringFromCGSize(size));
            
            uint32_t client = -1;
            while (client != 0) {
                client = [data readUInt32];
                if (client != 0) {
                    LogMessageCompat(@"%c%c%c%c", client >> 24, client >> 16, client >> 8, client);
                }
            }
        }
        
        _targaImage = [UIImage imageWithTargaData:data];
    }
    return self;
}

@end
