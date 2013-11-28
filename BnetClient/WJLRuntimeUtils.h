@interface WJLRuntimeUtils : NSObject

+ (NSArray *)namesOfClassesDirectlySubclassingClass:(Class)clazz;

+ (NSArray *)namesOfClassesConformingToProtocol:(Protocol *)protocol;

@end
