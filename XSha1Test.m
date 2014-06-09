#import <XCTest/XCTest.h>
#import "xsha1.h"

@interface XSha1Test : XCTestCase
@end

@implementation XSha1Test

- (void)testXSha1 {
    uint32_t result[5];
    uint32_t expectedResult[] = { 3472351533, 2232692810, 3848378821, 398953780, 3184268857 };
    const char *value = "this is a test string";

    xsha1_calcHashBuf(value, strlen(value), result);

    for (int i = 0; i < 5; i++) {
        XCTAssertEqual(result[i], expectedResult[i], @"result should be correct");
    }
}

@end
