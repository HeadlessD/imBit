//
//  UIButton+block.h
//  BiChat
//
//  Created by imac2 on 2018/7/19.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef void (^ActionBlock)(void);

@interface UIButton(Block)

- (void)handleControlEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action;

@end
