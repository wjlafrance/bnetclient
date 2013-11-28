#import "BNCPacketSidMessageBox.h"

#import "NSMutableData+PacketBuffer.h"

@implementation BNCPacketSidMessageBox

- (NSString *)name
{
    return @"SID_MESSAGEBOX";
}

- (long)identifier
{
    return SID_IDENTIFIER_BASE + SID_MESSAGEBOX;
}

- (NSData *)bncsResponseForPacket:(NSMutableData *)packet
           forBattleNetConnection:(BNCChatConnection *)__unused conn
{
    NSString *text    = [packet readString];
    NSString *caption = [packet readString];
    [[[UIAlertView alloc] initWithTitle:@"Battle.net Alert Box"
                                message:[NSString stringWithFormat:@"Text: %@\nCaption: %@", text, caption]
                              delegate:nil
                      cancelButtonTitle:@"Okay"
                      otherButtonTitles:nil] show];
    
    return nil;
}

@end
