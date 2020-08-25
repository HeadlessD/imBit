//
//  UILabel+Corner.m
//  coder
//
//  Created by 豆凯强 on 17/5/7.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "UILabel+Corner.h"

@implementation UIBarButtonItem (Lite)

+(UIBarButtonItem *) text:(NSString *)text selector:(SEL)selecor target:(id)target
{
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc]initWithString:text];
    CGFloat width = [DFAttStringManager getHeightWithContent:str withWidth:320].size.width;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor redColor];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:target action:selecor forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+(UIBarButtonItem *) icon:(NSString *)icon selector:(SEL)selecor target:(id)target
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [button setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [button addTarget:target action:selecor forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+(UIBarButtonItem *) back:(NSString *)title selector:(SEL)selecor target:(id)target
{
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc]initWithString:title];
    CGFloat width = [DFAttStringManager getHeightWithContent:str withWidth:320].size.width + 20;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:target action:selecor forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"icon_titlebar_back"] forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(1, -15, 0, 0)];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
