//
//  UITabBar+badge.h
//  BiChat
//
//  Created by worm_kc on 2018/5/21.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TabbarItemNums 5.0                  //tabbar的数量

@interface UITabBar (badge)

- (void)showBadgeOnItemIndex:(int)index;    //显示小红点
- (void)hideBadgeOnItemIndex:(int)index;    //隐藏小红点

@end
