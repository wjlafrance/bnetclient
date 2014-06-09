#import <XCTest/XCTest.h>

#import "NSData+BrokenSHA1.h"
#import "NSMutableData+PacketBuffer.h"

@interface NSMutableDataPacketBufferTest : XCTestCase

@property (strong) NSMutableData *data;

@end

@implementation NSMutableDataPacketBufferTest

- (void)setUp {
    self.data = [NSMutableData new];
}

- (void)testReadUInt8 {
    [self.data appendBytes:"\x03\x04\x05\x06\x07\x08\x09\x0A" length:8];
    unsigned int length = self.data.length;

    XCTAssertEqual((uint8_t) 0x03, [self.data readUInt8], @"reads correct value");
    XCTAssertEqual(length - 1, [self.data length], @"removed correct number of bytes");
}

- (void)testReadUInt16 {
    [self.data appendBytes:"\x03\x04\x05\x06\x07\x08\x09\x0A" length:8];
    unsigned int length = self.data.length;

    XCTAssertEqual((uint16_t) 0x0403, [self.data readUInt16], @"reads correct value");
    XCTAssertEqual(length - 2, [self.data length], @"removed correct number of bytes");
}

- (void)testReadUInt32 {
    [self.data appendBytes:"\x03\x04\x05\x06\x07\x08\x09\x0A" length:8];
    unsigned int length = self.data.length;

    XCTAssertEqual((uint32_t) 0x06050403, [self.data readUInt32], @"reads correct value");
    XCTAssertEqual(length - 4, [self.data length], @"removed correct number of bytes");
}

- (void)testReadUInt64 {
    [self.data appendBytes:"\x03\x04\x05\x06\x07\x08\x09\x0A" length:8];
    unsigned int length = self.data.length;

    XCTAssertEqual((uint64_t) 0x0A09080706050403, [self.data readUInt64], @"reads correct value");
    XCTAssertEqual(length - 8, [self.data length], @"removed correct number of bytes");
}

- (void)testReadStringWithLength {
    [self.data appendBytes:"test string\0test string" length:23];
    unsigned int length = self.data.length;

    XCTAssertEqualObjects(@"test ", [self.data readStringWithLength:5], @"reads correct value");
    XCTAssertEqual(length - 5, [self.data length], @"removed correct number of bytes");
}

- (void)testReadString {
    [self.data appendBytes:"test string\0test string" length:23];
    unsigned int length = self.data.length;

    XCTAssertEqualObjects(@"test string", [self.data readString], @"reads correct value");
    XCTAssertEqual(length - 12, [self.data length], @"removed correct number of bytes");
}

- (void)testWriteUInt8 {
    uint8_t value = 0x03;
    unsigned int length = self.data.length;

    [self.data writeUInt8:value];
    XCTAssertEqual(length + 1, [self.data length], @"added correct number of bytes");
    XCTAssertEqual(value, [self.data readUInt8], @"value written is correct");
}

- (void)testWriteUInt16 {
    uint16_t value = 0x0403;
    unsigned int length = self.data.length;

    [self.data writeUInt16:value];
    XCTAssertEqual(length + 2, [self.data length], @"added correct number of bytes");
    XCTAssertEqual(value, [self.data readUInt16], @"value written is correct");
}

- (void)testWriteUInt32 {
    uint32_t value = 0x06050403;
    unsigned int length = self.data.length;

    [self.data writeUInt32:value];
    XCTAssertEqual(length + 4, [self.data length], @"added correct number of bytes");
    XCTAssertEqual(value, [self.data readUInt32], @"value written is correct");
}

- (void)testWriteUInt64 {
    uint64_t value = 0x0A09080706050403;
    unsigned int length = self.data.length;

    [self.data writeUInt64:value];
    XCTAssertEqual(length + 8, [self.data length], @"added correct number of bytes");
    XCTAssertEqual(value, [self.data readUInt64], @"value written is correct");
}

- (void)testWriteString {
    NSString *value = @"this is a test string";
    unsigned int length = self.data.length;

    [self.data writeString:value];
    XCTAssertEqual(length + value.length + 1, [self.data length], @"added correct number of bytes");
    XCTAssertEqualObjects(value, [self.data readString], @"value written is correct");
}

- (void)testWriteStringWithoutNullTerminator {
    NSString *value = @"this is a test string";
    unsigned int length = self.data.length;

    [self.data writeStringWithoutNullTerminator:value];
    XCTAssertEqual(length + value.length, [self.data length], @"added correct number of bytes");
    XCTAssertEqualObjects(value, [self.data readStringWithLength:value.length], @"value written is correct");
}

@end
