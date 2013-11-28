#define kAddChatTextKey @"text"
#define kAddChatColorKey @"color"

@interface UITextView (AddChat)

- (void)addChat:(NSArray *)elements;

@end
