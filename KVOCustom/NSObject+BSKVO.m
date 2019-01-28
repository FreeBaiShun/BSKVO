//
//  NSObject+BSKVO.m
//  KVOCustom
//
//  Created by yuYue on 2019/1/25.
//  Copyright © 2019 yuYue. All rights reserved.
//

#import "NSObject+BSKVO.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (BSKVO)
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath valueChangeBlk:(void(^)(id old, id new))valueChangeBlk{
    //创建子类
    NSString *oldClass = NSStringFromClass(self.class);
    NSString *newClass = [NSString stringWithFormat:@"BSKVONotify_%@",oldClass];
    Class classNew = objc_allocateClassPair(self.class, newClass.UTF8String, 16);
    objc_registerClassPair(classNew);
    object_setClass(self, NSClassFromString(newClass));
    
    //新增set方法
    NSMutableString *strM = [NSMutableString string];
    [strM appendString:[[keyPath substringToIndex:1] uppercaseString]];
    [strM appendString:[keyPath substringFromIndex:1]];
    NSString *setMethod = [NSString stringWithFormat:@"set%@:",strM];
    class_addMethod(NSClassFromString(newClass), NSSelectorFromString(setMethod), (IMP)keyPathMethod,"v@:@");
    
    //新增class方法
    class_addMethod(classNew, NSSelectorFromString(@"class"), (IMP)classUse,"#@:");
    
    //新增_isKVOA方法
    class_addMethod(classNew, NSSelectorFromString(@"_isKVOA"),(IMP)_isKVOAUse, "i@:");
    
    //设置关联对象
    objc_setAssociatedObject(self, "keyPath", keyPath, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, "blk", valueChangeBlk, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, "classNew", classNew, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self, "classOld", self.class, OBJC_ASSOCIATION_RETAIN);
}

void keyPathMethod(id self,IMP _cmd, id arg){
    //set方法名,原始类和子类
    NSString *keyPath = objc_getAssociatedObject(self, "keyPath");
    NSMutableString *strM = [NSMutableString string];
    [strM appendString:[[keyPath substringToIndex:1] uppercaseString]];
    [strM appendString:[keyPath substringFromIndex:1]];
    NSString *setMethod = [NSString stringWithFormat:@"set%@:",strM];
    Class subClass = objc_getAssociatedObject(self, "classNew");
    Class oldClass = objc_getAssociatedObject(self,"classOld");
    
    //isa指针指向父类，执行set方法
    object_setClass(self, oldClass);
    //获取成员变量的值
    Ivar ivar = class_getInstanceVariable([self class], [NSString stringWithFormat:@"_%@",keyPath].UTF8String);
    id value = object_getIvar(self, ivar);
   // NSLog(@"old:%@",value);
    ((id (*) (id,SEL,id))objc_msgSend)(self,NSSelectorFromString(setMethod),arg);
    id valueNew = arg;
   // NSLog(@"new:%@",valueNew);
    
    //isa指针指向子类
    object_setClass(self, subClass);
    
    void(^blkUse)(id old, id new) = objc_getAssociatedObject(self, "blk");
    if (blkUse) {
        blkUse(value,valueNew);
    }
}
- (void)printMethods:(Class)cls{
    unsigned int count;
    Method *methods = class_copyMethodList(cls, &count);
    NSMutableString *strM = [NSMutableString string];
    [strM appendString:[NSString stringWithFormat:@"%@: ",cls]];
    
    for (int i  = 0; i < count; i++) {
        Method method = methods[i];
        NSString *strMethodName = NSStringFromSelector(method_getName(method));
        [strM appendString:strMethodName];
        [strM appendString:@", "];
    }
    NSLog(@"%@",strM);
    
}

Class classUse(id self,SEL _cmd){
    return class_getSuperclass(object_getClass(self));
}

int _isKVOAUse(id self,SEL _cmd){
    return YES;
}

@end
