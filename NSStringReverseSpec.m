#import "NSString+Reverse.h"

SPEC_BEGIN(NSStringReverseSpec)

describe(@"stringByReversingString", ^{
    it(@"should reverse the string", ^{
        [[[@"this is a test string" stringByReversingString] should] equal:@"gnirts tset a si siht"];
    });
});

SPEC_END
