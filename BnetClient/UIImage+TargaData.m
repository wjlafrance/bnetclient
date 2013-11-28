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
    
    int numPixels = size.height * size.width;
    for (int numPixelsWritten = 0; numPixelsWritten < numPixels; ) {
        uint8_t pixelCount = [data readUInt8];
        if ((pixelCount & 0x80) == 0x80) {
            // Most significant bit is set - read one pixel and write many times
            pixelCount -= 127;
            uint8_t blue = [data readUInt8];
            uint8_t green = [data readUInt8];
            uint8_t red = [data readUInt8];
            for (int pixel = 0; pixel < pixelCount; pixel++) {
                [pixelData writeUInt8:red];
                [pixelData writeUInt8:green];
                [pixelData writeUInt8:blue];
                [pixelData writeUInt8:1];
                numPixelsWritten++;
            }
        } else {
            // Most significant bit is not set - read many pixel and write once each
            pixelCount += 1;
            for (int pixel = 0; pixel < pixelCount; pixel++) {
                uint8_t blue = [data readUInt8];
                uint8_t green = [data readUInt8];
                uint8_t red = [data readUInt8];
                [pixelData writeUInt8:red];
                [pixelData writeUInt8:green];
                [pixelData writeUInt8:blue];
                [pixelData writeUInt8:1];
                numPixelsWritten++;
            }
        }
    }
    
    NSMutableData *flippedImage = [NSMutableData data];
    for (int row = size.height - 1; row >= 0; row--) {
        NSData *rowData = [pixelData subdataWithRange:NSMakeRange(row * size.width * 4, size.width * 4)];
        [flippedImage appendData:rowData];
    }
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, flippedImage.bytes, flippedImage.length, NULL);
    CGImageRef cgimage = CGImageCreate(size.width, size.height, 8, 32, 4 * size.width, colorspace,
                                       0, dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorspace);
    CGDataProviderRelease(dataProvider);
    
    self = [self initWithCGImage:cgimage];
    CGImageRelease(cgimage);
    
    return self;
}

@end
