@interface BNCIconsBni : NSObject

@property (strong) UIImage *targaImage;

- (instancetype)initWithPath:(NSString *)path;

/** Obtains an icon suitable for a user with given flags and client. First,
 * attempts to match flags. If none of the flag-specific images are suitable,
 * returns an image for the client. Returns nil if the client does not have an
 * image.
 */
- (UIImage *)imageForFlags:(uint32_t)flags client:(NSString *)client ATTR_PURE;

@end
