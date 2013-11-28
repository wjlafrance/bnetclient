#import "BNCColorManager.h"

@implementation BNCColorManager

+ (UIColor *)pendingColor ATTR_PURE
{
    // CSS YellowGreen: #9ACD32
    return [UIColor colorWithRed:0x9A / 255.0 green:0xCD / 255.0 blue:0x32 / 255.0 alpha:1];
}

+ (UIColor *)successColor ATTR_PURE
{
    // CSS Green: #008000
    return [UIColor colorWithRed:0 green:0x80 / 255.0 blue:0 alpha:1];
}

+ (UIColor *)channelStatusColor ATTR_PURE
{
    // CSS Green: #008000
    return [UIColor colorWithRed:0 green:0x80 / 255.0 blue:0 alpha:1];
}

+ (UIColor *)errorColor ATTR_PURE
{
    return [UIColor colorWithRed:0x80 / 255.0 green:0 blue:0 alpha:1];
}

+ (UIColor *)debugColor ATTR_PURE
{
    return [UIColor colorWithRed:0 green:0 blue:0x80 / 255.0 alpha:1];
}

+ (UIColor *)chatUsernameColor ATTR_PURE
{
    return [UIColor colorWithRed:0 green:0x80 / 255.0 blue:0 alpha:1];
}

+ (UIColor *)chatTextColor ATTR_PURE
{
    return [UIColor blackColor];
}

+ (UIColor *)timestampColor ATTR_PURE
{
    return [UIColor blackColor];
}

@end
