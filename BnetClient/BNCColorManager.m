#import "BNCColorManager.h"

@implementation BNCColorManager

+ (UIColor *)pendingColor ATTR_PURE
{
    // CSS: #FFFF35
    return [UIColor colorWithRed:255 green:255.0 blue:0x35 / 255.0 alpha:1];
}

+ (UIColor *)successColor ATTR_PURE
{
    // CSS: #55FF55
    return [UIColor colorWithRed:0x55 / 255.0 green:255 blue:0x55 / 255.0 alpha:1];
}

+ (UIColor *)channelStatusColor ATTR_PURE
{
    // CSS Green: #008000
    return [UIColor colorWithRed:0 green:0x80 / 255.0 blue:0 alpha:1];
}

+ (UIColor *)informationColor ATTR_PURE
{
    // CSS: #9999FF
    return [UIColor colorWithRed:0x99 / 255.0 green:0x99 / 255.0 blue:255 alpha:1];
}

+ (UIColor *)errorColor ATTR_PURE
{
    // CSS: FF3333
    return [UIColor colorWithRed:255.0 green:0x33 / 255.0 blue:0x33 / 255.0 alpha:1];
}

+ (UIColor *)debugColor ATTR_PURE
{
    // CSS: #6666FF
    return [UIColor colorWithRed:0x66 / 255.0 green:0x66 / 255.0 blue:255 alpha:1];
}

+ (UIColor *)chatUsernameColor ATTR_PURE
{
    // CSS: #55FF55
    return [UIColor colorWithRed:0x55 / 255.0 green:255 blue:0x55 / 255.0 alpha:1];
}

+ (UIColor *)chatTextColor ATTR_PURE
{
    return [UIColor whiteColor];
}

+ (UIColor *)timestampColor ATTR_PURE
{
    return [UIColor whiteColor];
}

@end
