#import "CALayer+NibConfiguration.h"

SPEC_BEGIN(CALayerNibConfigurationSpec)

    __block CALayer *layer;

    beforeEach(^{
        layer = [CALayer new];
    });

    describe(@"setBorderUIColor:", ^{
        it(@"should set borderColor", ^{
            [[[layer should] receive] setBorderColor:[UIColor redColor].CGColor];
            layer.borderUIColor = [UIColor redColor];
        });
    });

    describe(@"borderUIColor", ^{
        it(@"should set borderColor", ^{
            [[layer stubAndReturn:theValue([UIColor redColor].CGColor)] borderColor];
            [[layer.borderUIColor should] equal:[UIColor redColor]];
        });
    });

SPEC_END
