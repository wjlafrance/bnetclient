#import "BNCChatConnection.h"
#import "BNCFileTransferConnection.h"

@interface BNCChatViewController : UIViewController
    <BNCChatConnectionDelegate, BattleNetFileTransferProtocolDelegate,
    UITextFieldDelegate, UITableViewDataSource>

@end
