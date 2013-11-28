@interface NSData (BrokenSHA1)

- (NSData *)brokenSha1Hash;
- (NSData *)doubleBrokenSha1HashWithClientToken:(uint32_t)clientToken andServerToken:(uint32_t)serverToken;

@end
