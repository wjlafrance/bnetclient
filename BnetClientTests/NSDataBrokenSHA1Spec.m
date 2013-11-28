#import "NSData+BrokenSHA1.h"
#import "NSMutableData+PacketBuffer.h"
#import "xsha1.h"

SPEC_BEGIN(NSDataBrokenSHA1Spec)

describe(@"NSData+BrokenSHA1", ^{

    describe(@"brokenSha1Hash", ^{
        it(@"should be correct", ^{
            const char *data = "this is a test string";
            NSMutableData *result = [[[NSData dataWithBytes:data length:strlen(data)] brokenSha1Hash] mutableCopy];
            uint32_t expectedResult[] = { 3472351533, 2232692810, 3848378821, 398953780, 3184268857 };
            for (int i = 0; i < 5; i++) {
                [[@([result readUInt32]) should] equal:@(expectedResult[i])];
            }
        });
    });

    describe(@"doubleBrokenSha1HashWithClientToken:andServerToken:", ^{
        it(@"should be correct", ^{
            const char *data = "this is a test string";
            NSMutableData *result = [[[NSData dataWithBytes:data length:strlen(data)] doubleBrokenSha1HashWithClientToken:1234 andServerToken:5678] mutableCopy];
            uint32_t expectedResult[] = { 2132038710, 1856845190, 2731647891, 4052266518, 78135354 };
            for (int i = 0; i < 5; i++) {
                [[@([result readUInt32]) should] equal:@(expectedResult[i])];
            }
        });

    });
    
});

SPEC_END
