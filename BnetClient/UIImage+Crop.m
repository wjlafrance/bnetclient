#import "UIImage+Crop.h"

@implementation UIImage (Crop)

- (UIImage *)imageByCroppingToRect:(CGRect)rect ATTR_PURE
{
    CGImageRef cgimage = [self CGImage];
    CGImageRef croppedCgimage = CGImageCreateWithImageInRect(cgimage, rect);
    UIImage *cropped = [UIImage imageWithCGImage:croppedCgimage];
    CGImageRelease(croppedCgimage);
    return cropped;
}

@end
