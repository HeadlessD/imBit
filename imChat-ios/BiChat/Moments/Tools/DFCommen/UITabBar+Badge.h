//
//  UITabbar+Badge.h
//  coder
//
//  Created by 豆凯强 on 17/8/14.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (Badge)

- (void)showBadgeOnItemIndex:(int)index;
- (void)hideBadgeOnItemIndex:(int)index;
@end
