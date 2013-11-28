#import "UIImage+TargaData.h"

#import "NSMutableData+PacketBuffer.h"

@implementation UIImage (TargaData)

+ (instancetype)imageWithTargaData:(NSData *)targaData
{
    return [[self alloc] initWithTargaData:targaData];
}

- (instancetype)initWithTargaData:(NSData *)targaData
{
    NSMutableData *data = [targaData mutableCopy];
    NSMutableData *pixelData = [NSMutableData new];
    
    [data readUInt8];
    [data readUInt8]; // color map type, unsupported
    [data readUInt8]; // run length true color
    [data readUInt8]; // color map data, ignored
    [data readUInt8]; // color map data, ignored
    [data readUInt8]; // color map data, ignored
    [data readUInt8]; // color map data, ignored
    [data readUInt8]; // color map data, ignored
    [data readUInt16]; // xOrigin
    [data readUInt16]; // yOrigin
    CGSize size = CGSizeMake([data readUInt16], [data readUInt16]);
    [data readUInt8];
    [data readUInt8]; // start descriptor

    // Repeating pixels are compressed. Read one byte to get the run length.
    // If the most significant bit (0x80) is set, this is a run of identical
    // pixels. Read one and write it multiple times. Otherwise, it's a run of
    // different pixels.
    NSUInteger numPixels = size.height * size.width;
    for (NSUInteger numPixelsWritten = 0; numPixelsWritten < numPixels; ) {
        uint8_t runLength = [data readUInt8] + 1;
        if (runLength & 0x80) {
            runLength ^= 0x80; // Clear MSB
            uint32_t pixel = [self readAndCorrectPixelFromData:data];
            for (NSUInteger pixelIndex = 0; pixelIndex < runLength; pixelIndex++) {
                [pixelData writeUInt32:pixel];
                numPixelsWritten++;
            }
        } else {
            for (NSUInteger pixel = 0; pixel < runLength; pixel++) {
                [pixelData writeUInt32:[self readAndCorrectPixelFromData:data]];
                numPixelsWritten++;
            }
        }
    }

    // Now the image is uncompressed but upside down. Rewrite the image, row by
    // row.
    NSMutableData *flippedImage = [NSMutableData data];
    for (NSInteger row = size.height - 1; row >= 0; row--) {
        NSData *rowData = [pixelData subdataWithRange:NSMakeRange(row * size.width * 4, size.width * 4)];
        [flippedImage appendData:rowData];
    }
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, [flippedImage bytes], [flippedImage length], NULL);
    CGImageRef cgimage = CGImageCreate(size.width, size.height, 8, 32, 4 * size.width, colorspace,
                                       0, dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorspace);
    CGDataProviderRelease(dataProvider);
    
    self = [self initWithCGImage:cgimage];
    CGImageRelease(cgimage);
    
    return self;
}

// Targa stores pixels as BGR. Reorder as RGBA.
- (uint32_t)readAndCorrectPixelFromData:(NSMutableData *)data
{
    uint8_t blue = [data readUInt8];
    uint8_t green = [data readUInt8];
    uint8_t red = [data readUInt8];
    return red << 24 | blue << 16 | green << 8 | 1;
}

@end
