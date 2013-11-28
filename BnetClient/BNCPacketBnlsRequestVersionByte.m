#import "BNCPacketBnlsRequestVersionByte.h"

#import "BattleNetProduct.h"
#import "NSMutableData+PacketBuffer.h"

@implementation BNCPacketBnlsRequestVersionByte

- (NSString *)name
{
    return @"BNLS_REQUESTVERSIONBYTE";
}

- (long)identifier
{
    return BNLS_IDENTIFIER_BASE + BNLS_REQUESTVERSIONBYTE;
}

- (NSData *)packet
{
    NSMutableData *requestVersionByte = [NSMutableData new];
    [requestVersionByte writeUInt32:[BattleNetProduct currentProduct].bnlsProductCode];
    return [requestVersionByte buildBnlsPacketWithID:BNLS_REQUESTVERSIONBYTE];
}

- (NSData *)bncsResponseForPacket:(NSMutableData *)packet forBattleNetConnection:(BNCChatConnection *)__unused conn
{
    [packet readUInt32]; // BNLS echos product code
    uint32_t versionByte = [packet readUInt32];
    
    NSMutableData *response = [NSMutableData new];
    [response writeUInt32:0]; // Protocol ID
    [response writeUInt32:'IX86'];
    [response writeUInt32:[BattleNetProduct currentProduct].bncsProductCode];
    [response writeUInt32:versionByte]; // Version byte
    [response writeUInt32:0]; // Product Language
    [response writeUInt32:0]; // Local IP for NAT
    [response writeUInt32:0]; // Time zone bias
    [response writeUInt32:0]; // Locale ID
    [response writeUInt32:0]; // Language ID
    [response writeString:@"USA"];
    [response writeString:@"United States"];
    return [response buildBncsPacketWithID:0x50];
}

@end
