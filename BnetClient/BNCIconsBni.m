#import "BNCIconsBni.h"

#import "NSMutableData+PacketBuffer.h"
#import "UIImage+TargaData.h"
#import "UIImage+Crop.h"

@interface BNCIconsBni ()

@property (strong) NSMutableDictionary *iconIndexForFlags;
@property (strong) NSMutableDictionary *iconIndexForClient;

// Size of last image in the file. Assuming that all images will be the same
// size.
@property (assign) CGSize iconSize;

@end


@implementation BNCIconsBni

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _iconIndexForFlags = [NSMutableDictionary new];
        _iconIndexForClient = [NSMutableDictionary new];
        
        NSMutableData *data = [NSMutableData dataWithContentsOfFile:path];
        
        [data readUInt32]; // Header size
        [data readUInt16]; // BNI Version
        [data readUInt16]; // Alignment
        uint32_t nIcons = [data readUInt32];
        [data readUInt32]; // Data Offset


        for (NSUInteger iconIndex = 0; iconIndex < nIcons; iconIndex++) {
            uint32_t flags = [data readUInt32];
            if (flags) {
                [_iconIndexForFlags setObject:@(iconIndex) forKey:@(flags)];
            }

            _iconSize = CGSizeMake([data readUInt32], [data readUInt32]);

            // Each icon has a list of uint32_t client codes, followed by
            // (uint32_t)0 as a terminator.
            uint32_t client = [data readUInt32];
            while (client != 0) {
                NSString *clientString = [NSString stringWithFormat:@"%c%c%c%c", client >> 24, client >> 16, client >> 8, client];
                [_iconIndexForClient setObject:@(iconIndex) forKey:clientString];
                client = [data readUInt32];
            }
        }

        _targaImage = [UIImage imageWithTargaData:data];
    }
    return self;
}

- (UIImage *)imageAtIndex:(NSUInteger)index ATTR_PURE
{
    CGRect imageRect = { { 0, self.iconSize.height * index}, self.iconSize };
    return [self.targaImage imageByCroppingToRect:imageRect];
}

- (UIImage *)imageForFlags:(uint32_t)flags client:(NSString *)client ATTR_PURE
{
    // Check each flag individually, in ascending order.
    for (NSNumber *flag in [[self.iconIndexForFlags allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        if (flags & [flag integerValue]) {
            return [self imageAtIndex:[self.iconIndexForFlags[flag] integerValue]];
        }
    }

    // If no flag matches, return the icon for the client, if present.
    NSNumber *index = self.iconIndexForClient[client];
    return index ? [self imageAtIndex:[index integerValue]] : nil;
}

@end
