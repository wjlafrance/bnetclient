#import "BNCIconsBni.h"

@interface BNCIconsBni (Private)

@property (strong) NSMutableDictionary *iconIndexForFlags;
@property (strong) NSMutableDictionary *iconIndexForClient;

- (UIImage *)imageAtIndex:(NSUInteger)index ATTR_PURE;

@end

SPEC_BEGIN(BNCIconsBniSpec)

__block BNCIconsBni *icons = [BNCIconsBni new];

beforeEach(^{
    icons.iconIndexForFlags = [@{
        @2: @2,
        @1: @1
    } mutableCopy];
    icons.iconIndexForClient = [@{
        @"W2BN": @16
    } mutableCopy];
});

describe(@"imageForFlags:client:", ^{
    UIImage *correctImage = [UIImage nullMock];

    it(@"should return the image for the lowest numbered matching flag", ^{
        [[icons stubAndReturn:correctImage] imageAtIndex:1];
        [[[icons imageForFlags:3 client:@"W2BN"] should] equal:correctImage];
    });

    it(@"should return the image for the client if no flags match", ^{
        [[icons stubAndReturn:correctImage] imageAtIndex:16];
        [[[icons imageForFlags:0 client:@"W2BN"] should] equal:correctImage];
    });
});

SPEC_END
