//
//  WPBaseViewController+Tracking.m
//  BiChat
//
//  Created by 张迅 on 2018/4/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseViewController+Tracking.h"
#import <objc/runtime.h>

@implementation WPBaseViewController (Tracking)

+ (void)load{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(viewWillAppear:)),class_getInstanceMethod(self, @selector(tracking_viewWillAppear:)));
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(viewWillDisappear:)), class_getInstanceMethod(self, @selector(tracking_viewWillDisappear:)));
}

- (void)tracking_viewWillAppear:(BOOL)animated {
//    [self tracking_viewWillAppear:animated];
//    NSLog(@"当前viewController :%@",NSStringFromClass([self class]));
}

- (void)tracking_viewWillDisappear:(BOOL)animated {
//    [self tracking_viewWillDisappear:animated];
//    NSLog(@"当前viewController :%@",NSStringFromClass([self class]));
}

@end
