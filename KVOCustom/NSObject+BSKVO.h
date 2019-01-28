//
//  NSObject+BSKVO.h
//  KVOCustom
//
//  Created by yuYue on 2019/1/25.
//  Copyright © 2019 yuYue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (BSKVO)
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath valueChangeBlk:(void(^)(id old, id new))valueChangeBlk;

- (void)printMethods:(Class)cls;
@end

NS_ASSUME_NONNULL_END
