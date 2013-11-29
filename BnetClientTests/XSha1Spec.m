#import "xsha1.h"

SPEC_BEGIN(XSha1Spec)

describe(@"XSha1", ^{

    it(@"should calculate a hash correctly", ^{
        uint32_t result[5];
        uint32_t expectedResult[] = { 3472351533, 2232692810, 3848378821, 398953780, 3184268857 };
        const char *value = "this is a test string";
        xsha1_calcHashBuf(value, strlen(value), result);
        for (int i = 0; i < 5; i++) {
            [[@(result[i]) should] equal:@(expectedResult[i])];
        }
    });

});

SPEC_END
