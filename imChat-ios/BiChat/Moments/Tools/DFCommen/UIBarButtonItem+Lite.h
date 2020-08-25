//
//  UILabel+Corner.h
//  coder
//
//  Created by 豆凯强 on 17/5/7.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Lite)

+(UIBarButtonItem *) text:(NSString *)text selector:(SEL)selecor target:(id)target;
+(UIBarButtonItem *) icon:(NSString *)icon selector:(SEL)selecor target:(id)target;
+(UIBarButtonItem *) back:(NSString *)title selector:(SEL)selecor target:(id)target;


@end
