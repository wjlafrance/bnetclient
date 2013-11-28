#import "CALayer+NibConfiguration.h"

@implementation CALayer (NibConfiguration)

- (void)setBorderUIColor:(UIColor *)borderUIColor
{
    self.borderColor = borderUIColor.CGColor;
}

- (UIColor *)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end
