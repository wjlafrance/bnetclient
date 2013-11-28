#import "BNCChatViewController.h"

#import "BNCChatConnection.h"
#import "UITextView+AddChat.h"
#import "BNCColorManager.h"
#import "BNCIconsBni.h"

@interface BNCChatViewController ()

@property (weak, nonatomic) IBOutlet UITextView  *chatBox;
@property (weak, nonatomic) IBOutlet UILabel     *channelLabel;
@property (weak, nonatomic) IBOutlet UITableView *channelList;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomSpaceConstraint;

@property (strong) NSMutableArray *channelUsers;

@property (strong) BNCChatConnection *connection;

@end

@implementation BNCChatViewController

- (void)awakeFromNib
{
    self.connection = [[BNCChatConnection alloc] initWithDelegate:self];
}

- (void)viewDidAppear:(BOOL)__unused animated
{
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)__unused toInterfaceOrientation
                                duration:(NSTimeInterval)__unused duration
{
    [self.textField resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)__unused animated
{
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:UIKeyboardWillChangeFrameNotification
                                                object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
}

// Dirty hack - sometimes the keyboard width is actually the height, when device is in landscape
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = MIN(keyboardFrame.size.height, keyboardFrame.size.width);

    self.textViewBottomSpaceConstraint.constant = 50 + height;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.textViewBottomSpaceConstraint.constant = 50;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)__unused textField
{
    [self.connection sendText:self.textField.text];
    self.textField.text = @"";    
    return NO;
}

- (NSString *)stringForBattleNetService:(BattleNetService)service
{
    switch (service) {
        case BNCS: return @"BNET";
        case BNLS: return @"BNLS";
        default: return nil;
    }
}

#pragma mark - BattleNet Connection Delegate: Debug outputs

- (void)battleNetConnection:(BNCChatConnection *)__unused conn
    outputDebugString:(NSString *)string
{
    [self.chatBox addChat:@[@{
        kAddChatColorKey: [BNCColorManager debugColor],
        kAddChatTextKey: string
    }]];
}

#pragma mark - BattleNet Connection Delegate: Socket connection callbacks

- (void)battleNetConnection:(BNCChatConnection *)__unused conn
    didBeginConnectingToService:(BattleNetService)service
{
    [self.chatBox addChat:@[@{
        kAddChatColorKey: [BNCColorManager pendingColor],
        kAddChatTextKey: [NSString stringWithFormat:@"[%@] Connecting...", [self stringForBattleNetService:service]]
    }]];
}

- (void)battleNetConnection:(BNCChatConnection *)__unused conn
    didConnectToService:(BattleNetService)service
{
    [self.chatBox addChat:@[@{
        kAddChatColorKey: [BNCColorManager successColor],
        kAddChatTextKey: [NSString stringWithFormat:@"[%@] Connected!", [self stringForBattleNetService:service]]
    }]];
}

- (void)battleNetConnection:(BNCChatConnection *)__unused conn
   didDisconnectFromService:(BattleNetService)service
                  withError:(NSString *)error
{
    [self.chatBox addChat:@[@{
        kAddChatColorKey: [BNCColorManager errorColor],
        kAddChatTextKey: [NSString stringWithFormat:@"[%@] Disconnected: %@", [self stringForBattleNetService:service], error]
    }]];
}

- (void)battleNetConnection:(BNCChatConnection *)__unused conn
    didBeginCreatingAccountForService:(BattleNetService)service
{
    [self.chatBox addChat:@[@{
        kAddChatColorKey: [BNCColorManager pendingColor],
        kAddChatTextKey: [NSString stringWithFormat:@"[%@] Creating account.. ", [self stringForBattleNetService:service]]
    }]];
}

- (void)battleNetConnection:(BNCChatConnection *)__unused conn
    didCreateAccountForService:(BattleNetService)service
{
    [self.chatBox addChat:@[@{
        kAddChatColorKey: [BNCColorManager pendingColor],
        kAddChatTextKey: [NSString stringWithFormat:@"[%@] Created account! ", [self stringForBattleNetService:service]]
    }]];
}

#pragma mark - BattleNet Connection Delegate: Client Authentication

- (void)battleNetConnection:(BNCChatConnection *)__unused conn
    didBeginAuthenticatingClientToService:(BattleNetService)service
{
    [self.chatBox addChat:@[@{
        kAddChatColorKey: [BNCColorManager pendingColor],
        kAddChatTextKey: [NSString stringWithFormat:@"[%@] Authenticating...", [self stringForBattleNetService:service]]
    }]];
}

- (void)battleNetConnection:(BNCChatConnection *)__unused conn
    didAuthenticateClientToService:(BattleNetService)service
{
    [self.chatBox addChat:@[@{
        kAddChatColorKey: [BNCColorManager successColor],
        kAddChatTextKey: [NSString stringWithFormat:@"[%@] Authenticated!", [self stringForBattleNetService:service]]
    }]];
}

- (void)battleNetConnection:(BNCChatConnection *)__unused conn
    didFailToAuthenticateClientToService:(BattleNetService)service
    withError:(NSString *)error
{
    [self.chatBox addChat:@[@{
        kAddChatColorKey: [BNCColorManager errorColor],
        kAddChatTextKey: [NSString stringWithFormat:@"[%@] Authentication failed: %@", [self stringForBattleNetService:service], error]
    }]];
}

#pragma mark - BattleNet Connection Delegate: User Authentication

- (void)battleNetConnection:(BNCChatConnection *)__unused conn
    didBeginAuthenticatingUserToService:(BattleNetService)service
{
    [self.chatBox addChat:@[@{
        kAddChatColorKey: [BNCColorManager pendingColor],
        kAddChatTextKey: [NSString stringWithFormat:@"[%@] Logging in..", [self stringForBattleNetService:service]]
    }]];
}

- (void)battleNetConnection:(BNCChatConnection *)__unused conn
    didAuthenticateUserToService:(BattleNetService)service
{
    [self.chatBox addChat:@[@{
        kAddChatColorKey: [BNCColorManager successColor],
        kAddChatTextKey: [NSString stringWithFormat:@"[%@] Logged in!", [self stringForBattleNetService:service]]
    }]];
}

- (void)battleNetConnection:(BNCChatConnection *)__unused conn
    didFailToAuthenticateUserToService:(BattleNetService)service
    withError:(NSError *)error
{
    [self.chatBox addChat:@[@{
        kAddChatColorKey: [BNCColorManager errorColor],
        kAddChatTextKey: [NSString stringWithFormat:@"[%@] Login failed: %@", [self stringForBattleNetService:service], error]
    }]];
}

#pragma mark - BattleNet Connection Delegate: Chat events

- (void)battleNetConnection:(BNCChatConnection *)__unused conn
    eventDidOccur:(BattleNetEvent)event
    username:(NSString *)username
    text:(NSString *)text
    flags:(BattleNetFlags)flags
    ping:(uint32_t)__unused ping
{
    switch (event) {
        case EID_SHOWUSER:
            [self.channelUsers addObject:username];
            [self.channelList reloadData];
            break;

        case EID_JOIN:
            [self.channelUsers addObject:username];
            [self.channelList reloadData];
            [self.chatBox addChat:@[@{
                kAddChatColorKey: [BNCColorManager successColor],
                kAddChatTextKey: [NSString stringWithFormat:@"%@ has joined the channel.", username]
            }]];
            break;

        case EID_LEAVE:
            [self.channelUsers removeObject:username];
            [self.channelList reloadData];
            [self.chatBox addChat:@[@{
                kAddChatColorKey: [BNCColorManager channelStatusColor],
                kAddChatTextKey: [NSString stringWithFormat:@"%@ has left the channel.", username]
            }]];
            break;

        case EID_TALK:
            [self.chatBox addChat:@[@{
                kAddChatColorKey: [BNCColorManager chatUsernameColor],
                kAddChatTextKey: [NSString stringWithFormat:@"<%@> ", username]
            }, @{
                kAddChatColorKey: [BNCColorManager chatTextColor],
                kAddChatTextKey: text
            }]];
            break;

        case EID_CHANNEL:
            self.channelUsers = [NSMutableArray new];
            [self.channelList reloadData];
            self.channelLabel.text = text;
            [self.chatBox addChat:@[@{
                kAddChatColorKey: [BNCColorManager successColor],
                kAddChatTextKey: [NSString stringWithFormat:@"Joined channel %@", text]
            }]];
            break;

        case EID_USERFLAGS:
            [self.chatBox addChat:@[@{
                kAddChatColorKey: [BNCColorManager chatTextColor],
                kAddChatTextKey: [NSString stringWithFormat:@"Flags updated for %@ (0x%X).", username, flags]
            }]];
            break;

        case EID_INFO:
            [self.chatBox addChat:@[@{
                kAddChatColorKey: [BNCColorManager debugColor],
                kAddChatTextKey: text
            }]];
            break;

        case EID_ERROR:
            [self.chatBox addChat:@[@{
                kAddChatColorKey: [BNCColorManager errorColor],
                kAddChatTextKey: text
            }]];
            break;

        default:
            [self.chatBox addChat:@[@{
                kAddChatColorKey: [BNCColorManager debugColor],
                kAddChatTextKey: [NSString stringWithFormat:@"Unhandled chat event 0x%02X (%@, %@)", event, username, text]
            }]];
    }
}

#pragma mark - BNFTP Delegate

- (void)bnftp:(BNCFileTransferConnection *)bnftp didFailWithError:(NSError *)err
{
    [self.chatBox addChat:@[@{
        kAddChatColorKey: [BNCColorManager errorColor],
        kAddChatTextKey: [NSString stringWithFormat:@"[BNFTP] Failed to download %@: %@",
                          bnftp.filename, err]
    }]];
}

- (void)bnftp:(BNCFileTransferConnection *)bnftp didFinishDownload:(NSString *)__unused path
{
    [self.chatBox addChat:@[@{
        kAddChatColorKey: [BNCColorManager successColor],
        kAddChatTextKey: [NSString stringWithFormat:@"[BNFTP] Downloaded %@ to %@",
                            bnftp.filename, bnftp.path]
    }]];

    BNCIconsBni *bni = [BNCIconsBni new];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bni.targaImage];
    [self.view addSubview:imageView];
    imageView.frame = CGRectMake(0, 0, 28, 280);

    [UIView animateWithDuration:10.0 animations:^{
        imageView.frame = CGRectMake(0, 0, 28*3, 280*3);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section
{
    return [self.channelUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];

    cell.textLabel.text = self.channelUsers[indexPath.row];

    return cell;
}

@end
