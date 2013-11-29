#import "UITextView+AddChat.h"

#import "BNCColorManager.h"

@implementation UITextView (AddChat)

- (UIFont *)chatFont ATTR_CONST
{
    static UIFont *chatFont;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chatFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    });
    return chatFont;
}

- (void)addChat:(NSArray *)elements
{
    NSMutableAttributedString *textViewContents = [self.attributedText mutableCopy];
    
    for (NSDictionary *element in [self addTimestampToElements:elements]) {
        NSMutableAttributedString *currentElement =
            [[NSMutableAttributedString alloc] initWithString:element[kAddChatTextKey]];
        
        [currentElement setAttributes:@{
            NSForegroundColorAttributeName: element[kAddChatColorKey],
            NSFontAttributeName: [self chatFont]
        } range:NSMakeRange(0, currentElement.length)];
        
        [textViewContents appendAttributedString:currentElement];
    }
    [textViewContents appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    
    self.attributedText = textViewContents;
    [self scrollRangeToVisible:NSMakeRange(self.text.length, 0)];
}

- (NSArray *)addTimestampToElements:(NSArray *)elements
{
    NSString *timestamp = [NSString stringWithFormat:@"[%@] ",
                           [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterNoStyle
                                                          timeStyle:NSDateFormatterMediumStyle]];
    
    NSMutableArray *mutableElements = [elements mutableCopy];
    [mutableElements insertObject:@{
        kAddChatTextKey: timestamp,
        kAddChatColorKey: [BNCColorManager timestampColor]
    } atIndex:0];
    return mutableElements;
}

@end
