@class BNCFileTransferConnection;

@protocol BattleNetFileTransferProtocolDelegate <NSObject>

- (void)bnftp:(BNCFileTransferConnection *)bnftp didFailWithError:(NSError *)err;
- (void)bnftp:(BNCFileTransferConnection *)bnftp didFinishDownload:(NSString *)path;

@end


@interface BNCFileTransferConnection : NSObject <AsyncSocketDelegate>

@property (weak) id<BattleNetFileTransferProtocolDelegate> delegate;
@property (strong) NSString *filename;
@property (strong) NSString *path;

- (void)downloadFile:(NSString *)file toPath:(NSString *)path;

@end
