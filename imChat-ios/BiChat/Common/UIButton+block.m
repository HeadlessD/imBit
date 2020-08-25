//
//  UIButton+block.m
//  BiChat
//
//  Created by imac2 on 2018/7/19.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "UIButton+block.h"

@implementation UIButton(Block)

static char overviewKey;

- (void)handleControlEvent:(UIControlEvents)event withBlock:(ActionBlock)block {
    objc_setAssociatedObject(self, &overviewKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
}

- (void)callActionBlock:(id)sender {
    ActionBlock block = (ActionBlock)objc_getAssociatedObject(self, &overviewKey);
    if (block) {
        block();
    }
}

@end
