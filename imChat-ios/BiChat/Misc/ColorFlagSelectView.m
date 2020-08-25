//
//  ColorFlagSelectView.m
//  BiChat
//
//  Created by Admin on 2018/5/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "ColorFlagSelectView.h"

@implementation ColorFlagSelectView

- (id)init
{
    self = [super init];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (isIphonex)
        self.frame = CGRectMake(0, 0, ScreenWidth, 160);
    else
        self.frame = CGRectMake(0, 0, screenWidth, 130);
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    [self createGUI];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)createGUI
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    UIButton *button4Red = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth / 2 - 160, 20, 40, 40)];
    button4Red.tag = 1;
    UIView *view4RedFlag = [[UIView alloc]initWithFrame:CGRectMake(8, 8, 24, 24)];
    view4RedFlag.backgroundColor = [UIColor redColor];
    view4RedFlag.layer.cornerRadius = 12;
    view4RedFlag.clipsToBounds = YES;
    view4RedFlag.userInteractionEnabled = NO;
    [button4Red addSubview:view4RedFlag];
    [button4Red addTarget:self action:@selector(onButtonColor:) forControlEvents:UIControlEventTouchUpInside];
    [button4Red setBackgroundImage:[UIImage imageNamed:@"gray"] forState:UIControlStateHighlighted];
    [self addSubview:button4Red];
    
    UIButton *button4Orange = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth / 2 - 120, 20, 40, 40)];
    button4Orange.tag = 2;
    UIView *view4OrangeFlag = [[UIView alloc]initWithFrame:CGRectMake(8, 8, 24, 24)];
    view4OrangeFlag.backgroundColor = [UIColor orangeColor];
    view4OrangeFlag.layer.cornerRadius = 12;
    view4OrangeFlag.clipsToBounds = YES;
    view4OrangeFlag.userInteractionEnabled = NO;
    [button4Orange addSubview:view4OrangeFlag];
    [button4Orange addTarget:self action:@selector(onButtonColor:) forControlEvents:UIControlEventTouchUpInside];
    [button4Orange setBackgroundImage:[UIImage imageNamed:@"gray"] forState:UIControlStateHighlighted];
    [self addSubview:button4Orange];
 
    UIButton *button4Yellow = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth / 2 - 80, 20, 40, 40)];
    button4Yellow.tag = 3;
    UIView *view4YellowFlag = [[UIView alloc]initWithFrame:CGRectMake(8, 8, 24, 24)];
    view4YellowFlag.backgroundColor = THEME_YELLOW;
    view4YellowFlag.layer.cornerRadius = 12;
    view4YellowFlag.clipsToBounds = YES;
    view4YellowFlag.userInteractionEnabled = NO;
    [button4Yellow addSubview:view4YellowFlag];
    [button4Yellow addTarget:self action:@selector(onButtonColor:) forControlEvents:UIControlEventTouchUpInside];
    [button4Yellow setBackgroundImage:[UIImage imageNamed:@"gray"] forState:UIControlStateHighlighted];
    [self addSubview:button4Yellow];

    UIButton *button4Green = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth / 2 - 40, 20, 40, 40)];
    button4Green.tag = 4;
    UIView *view4GreenFlag = [[UIView alloc]initWithFrame:CGRectMake(8, 8, 24, 24)];
    view4GreenFlag.backgroundColor = THEME_GREEN;
    view4GreenFlag.layer.cornerRadius = 12;
    view4GreenFlag.clipsToBounds = YES;
    view4GreenFlag.userInteractionEnabled = NO;
    [button4Green addSubview:view4GreenFlag];
    [button4Green addTarget:self action:@selector(onButtonColor:) forControlEvents:UIControlEventTouchUpInside];
    [button4Green setBackgroundImage:[UIImage imageNamed:@"gray"] forState:UIControlStateHighlighted];
    [self addSubview:button4Green];

    UIButton *button4Blue = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth / 2 + 0, 20, 40, 40)];
    button4Blue.tag = 5;
    UIView *view4BlueFlag = [[UIView alloc]initWithFrame:CGRectMake(8, 8, 24, 24)];
    view4BlueFlag.backgroundColor = THEME_COLOR;
    view4BlueFlag.layer.cornerRadius = 12;
    view4BlueFlag.clipsToBounds = YES;
    view4BlueFlag.userInteractionEnabled = NO;
    [button4Blue addSubview:view4BlueFlag];
    [button4Blue addTarget:self action:@selector(onButtonColor:) forControlEvents:UIControlEventTouchUpInside];
    [button4Blue setBackgroundImage:[UIImage imageNamed:@"gray"] forState:UIControlStateHighlighted];
    [self addSubview:button4Blue];

    UIButton *button4Purple = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth / 2 + 40, 20, 40, 40)];
    button4Purple.tag = 6;
    UIView *view4PurpleFlag = [[UIView alloc]initWithFrame:CGRectMake(8, 8, 24, 24)];
    view4PurpleFlag.backgroundColor = [UIColor purpleColor];
    view4PurpleFlag.layer.cornerRadius = 12;
    view4PurpleFlag.clipsToBounds = YES;
    view4PurpleFlag.userInteractionEnabled = NO;
    [button4Purple addSubview:view4PurpleFlag];
    [button4Purple addTarget:self action:@selector(onButtonColor:) forControlEvents:UIControlEventTouchUpInside];
    [button4Purple setBackgroundImage:[UIImage imageNamed:@"gray"] forState:UIControlStateHighlighted];
    [self addSubview:button4Purple];
    
    UIButton *button4Gray = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth / 2 + 80, 20, 40, 40)];
    button4Gray.tag = 7;
    UIView *view4GrayFlag = [[UIView alloc]initWithFrame:CGRectMake(8, 8, 24, 24)];
    view4GrayFlag.backgroundColor = [UIColor grayColor];
    view4GrayFlag.layer.cornerRadius = 12;
    view4GrayFlag.clipsToBounds = YES;
    view4GrayFlag.userInteractionEnabled = NO;
    [button4Gray addSubview:view4GrayFlag];
    [button4Gray addTarget:self action:@selector(onButtonColor:) forControlEvents:UIControlEventTouchUpInside];
    [button4Gray setBackgroundImage:[UIImage imageNamed:@"gray"] forState:UIControlStateHighlighted];
    [self addSubview:button4Gray];
    
    UIButton *button4Clear = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth / 2 + 120, 20, 40, 40)];
    button4Clear.tag = 0;
    UIView *view4ClearFlag = [[UIView alloc]initWithFrame:CGRectMake(8, 8, 24, 24)];
    view4ClearFlag.layer.cornerRadius = 12;
    view4ClearFlag.layer.borderColor = [UIColor grayColor].CGColor;
    view4ClearFlag.layer.borderWidth = 0.5;
    view4ClearFlag.userInteractionEnabled = NO;
    [button4Clear addSubview:view4ClearFlag];
    [button4Clear addTarget:self action:@selector(onButtonColor:) forControlEvents:UIControlEventTouchUpInside];
    [button4Clear setBackgroundImage:[UIImage imageNamed:@"gray"] forState:UIControlStateHighlighted];
    [self addSubview:button4Clear];
    
    UIButton *button4Cancel = [[UIButton alloc]initWithFrame:CGRectMake(0, 80, screenWidth, 50)];
    button4Cancel.backgroundColor = [UIColor whiteColor];
    [button4Cancel setTitle:LLSTR(@"101002") forState:UIControlStateNormal];
    [button4Cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button4Cancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4Cancel addTarget:self action:@selector(onButtonCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button4Cancel];
}

- (void)onButtonColor:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag;
    
    //开始回调
    if (self.colorHandle)
        self.colorHandle(index);
}

- (void)onButtonCancel:(id)sender
{
    //开始回调
    if (self.cancelHandle)
        self.cancelHandle();
}

+ (UIColor *)getFlagColor:(NSInteger)flag
{
    switch (flag) {
        case 0: return [UIColor clearColor]; break;
        case 1: return [UIColor redColor]; break;
        case 2: return [UIColor orangeColor]; break;
        case 3: return THEME_YELLOW; break;
        case 4: return THEME_GREEN; break;
        case 5: return THEME_COLOR; break;
        case 6: return [UIColor purpleColor]; break;
        case 7: return [UIColor grayColor]; break;
        default:
            break;
    }
    return [UIColor clearColor];
}

@end
