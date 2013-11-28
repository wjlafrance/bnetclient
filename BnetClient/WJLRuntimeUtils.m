#import "WJLRuntimeUtils.h"

@implementation WJLRuntimeUtils

+ (NSArray *)namesOfClassesDirectlySubclassingClass:(Class)clazz
{
    return [[self loadedClasses] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *className, __unused NSDictionary *bindings) {
        Class clazzToTest = NSClassFromString(className);
        return clazz == class_getSuperclass(clazzToTest);
    }]];
}

+ (NSArray *)namesOfClassesConformingToProtocol:(Protocol *)protocol
{
    return [[self loadedClasses] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *className, __unused NSDictionary *bindings) {
        Class clazzToTest = NSClassFromString(className);
        return class_conformsToProtocol(clazzToTest, protocol);
    }]];
}

+ (NSArray *)loadedClasses
{
    unsigned int classesCount;
    Class *classes = objc_copyClassList(&classesCount);
    
    NSMutableArray *classNames = [[NSMutableArray alloc] initWithCapacity:classesCount];
    for (NSUInteger i = 0; i < classesCount; i++) {
        [classNames addObject:NSStringFromClass(classes[i])];
    }
    
    free(classes);
    return classNames;
}

@end
