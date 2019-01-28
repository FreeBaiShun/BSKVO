//
//  ViewController.m
//  KVOCustom
//
//  Created by yuYue on 2019/1/25.
//  Copyright © 2019 yuYue. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+BSKVO.h"
#import "Person.h"
#import <objc/runtime.h>

int count = 0;
@interface ViewController ()

@end

@implementation ViewController{
    Person *p1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    p1 = [[Person alloc] init];
    [p1 addObserver:self forKeyPath:@"name" valueChangeBlk:^(id  _Nonnull old, id  _Nonnull new) {
        NSLog(@"old:%@, new:%@",old,new);
    }];
    
//    [self addObserver:self forKeyPath:@"str" options:NSKeyValueObservingOptionNew context:nil];
//    [self willChangeValueForKey:@"str"];
//    _str = @"1";
//    [self didChangeValueForKey:@"str"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    count++;
    p1.name = [NSString stringWithFormat:@"%d",count];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
}

@end
