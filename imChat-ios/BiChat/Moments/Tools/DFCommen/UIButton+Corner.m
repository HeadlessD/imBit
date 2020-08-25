//
//  UILabel+Corner.m
//  coder
//
//  Created by 豆凯强 on 17/5/7.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "UIButton+Corner.h"

@implementation UIButton (Corner)

+(UIButton *) cornerButton:(UIColor *) bgColor text:(NSString *) text font:(UIFont *)font textColor:(UIColor *)textColor;
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setTitleColor: textColor forState:UIControlStateNormal];
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    button.backgroundColor = bgColor;
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = font;
    return button;
    
}

+(UIButton *) cornerButton:(UIColor *) bgColor text:(NSString *) text font:(UIFont *)font
{
    return [UIButton cornerButton:bgColor text:text font:font textColor:[UIColor whiteColor]];
}
+(UIButton *) cornerButton:(UIColor *) bgColor text:(NSString *) text
{
    return [UIButton cornerButton:bgColor text:text font:[UIFont systemFontOfSize:16]];
}
@end
