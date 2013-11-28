#import "NSMutableData+PacketBuffer.h"

SPEC_BEGIN(NSMutableDataPacketBufferSpec)

describe(@"NSMutableData+PacketBuffer", ^{

    __block NSMutableData *buffer;

    NSInteger(^bufferLength)(void) = ^NSInteger(void) { return [buffer length]; };

    beforeEach(^{
        buffer = [NSMutableData new];
    });

    context(@"reading", ^{
        context(@"reading ints", ^{
            beforeEach(^{
                [buffer appendBytes:"\x03\x04\x05\x06\x07\x08\x09\x0A" length:8];
            });

            describe(@"readUInt8", ^{
                it(@"should return the first uint8_t", ^{
                    [[@([buffer readUInt8]) should] equal:@0x03];
                });
                it(@"should remove 1 byte from the buffer", ^{
                    [[theBlock(^{ [buffer readUInt8]; }) should] change:bufferLength by:-1];
                });
            });

            describe(@"readUInt16", ^{
                it(@"should return the first uint16_t", ^{
                    [[@([buffer readUInt16]) should] equal:@0x0403];
                });
                it(@"should remove 2 bytes from the buffer", ^{
                    [[theBlock(^{ [buffer readUInt16]; }) should] change:bufferLength by:-2];
                });
            });

            describe(@"readUInt32", ^{
                it(@"should return the first uint32_t", ^{
                    [[@([buffer readUInt32]) should] equal:@0x06050403];
                });
                it(@"should remove 4 bytes from the buffer", ^{
                    [[theBlock(^{ [buffer readUInt32]; }) should] change:bufferLength by:-4];
                });
            });

            describe(@"readUInt64", ^{
                it(@"should return the first uint64_t", ^{
                    [[@([buffer readUInt64]) should] equal:@0x0A09080706050403];
                });
                it(@"should remove 8 bytes from the buffer", ^{
                    [[theBlock(^{ [buffer readUInt64]; }) should] change:bufferLength by:-8];
                });
            });
        });

        context(@"reading strings", ^{
            beforeEach(^{
                [buffer appendBytes:"test string\0test string" length:23];
            });

            describe(@"readStringWithLength:", ^{
                it(@"should return the string, stopping after length", ^{
                    [[[buffer readStringWithLength:5] should] equal:@"test "];
                });
                it(@"should remove the read bytes from the buffer", ^{
                    [[theBlock(^{ [buffer readStringWithLength:15]; }) should] change:bufferLength by:-15];
                });
            });

            describe(@"readString:", ^{
                it(@"should return the string, stopping after null termination", ^{
                    [[[buffer readString] should] equal:@"test string"];
                });
                it(@"should remove the read bytes from the buffer", ^{
                    [[theBlock(^{ [buffer readString]; }) should] change:bufferLength by:-12];
                });
            });
        });
    });

    context(@"writing", ^{
        context(@"writing integers", ^{
            describe(@"writeUInt8:", ^{
                it(@"should write the value to the buffer", ^{
                    uint8_t value = 0x03;
                    [[theBlock(^{ [buffer writeUInt8:value]; }) should] change:bufferLength by:+1];
                    [[@([buffer readUInt8]) should] equal:@(value)];
                });
            });

            describe(@"writeUInt16:", ^{
                it(@"should write the value to the buffer", ^{
                    uint16_t value = 0x0403;
                    [[theBlock(^{ [buffer writeUInt16:value]; }) should] change:bufferLength by:+2];
                    [[@([buffer readUInt16]) should] equal:@(value)];
                });
            });

            describe(@"writeUInt32:", ^{
                it(@"should write the value to the buffer", ^{
                    uint32_t value = 0x06050403;
                    [[theBlock(^{ [buffer writeUInt32:value]; }) should] change:bufferLength by:+4];
                    [[@([buffer readUInt32]) should] equal:@(value)];
                });
            });

            describe(@"writeUInt64:", ^{
                it(@"should write the value to the buffer", ^{
                    uint64_t value = 0x0A09080706050403;
                    [[theBlock(^{ [buffer writeUInt64:value]; }) should] change:bufferLength by:+8];
                    [[@([buffer readUInt64]) should] equal:@(value)];
                });
            });
        });

        context(@"writing strings", ^{
            describe(@"writeString:", ^{
                it(@"should write the string to the buffer followed by a null byte", ^{
                    NSString *value = @"this is a test string";
                    [[theBlock(^{ [buffer writeString:value]; }) should] change:bufferLength by:[value length] + 1];
                    [[[buffer readString] should] equal:value];
                });
            });

            describe(@"writeStringWithoutNullTerminator", ^{
                it(@"should write the string to the buffer, followed by a null byte", ^{
                    NSString *value = @"this is a test string";
                    [[theBlock(^{ [buffer writeStringWithoutNullTerminator:value]; }) should] change:bufferLength by:[value length]];
                    [[[buffer readStringWithLength:[value length]] should] equal:value];
                });
            });
        });
    });
});

SPEC_END
