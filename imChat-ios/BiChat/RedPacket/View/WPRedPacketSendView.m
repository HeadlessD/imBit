//
//  WPRedPacketSendView.m
//  BiChat
//
//  Created by 张迅 on 2018/5/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedPacketSendView.h"

@implementation WPRedPacketSendView

- (id)init {
    self = [super init];
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
//    self.layer.borderColor = RGB(0xe5e5e5).CGColor;
//    self.layer.borderWidth = 1;
    
    self.titleTF = [[UITextField alloc]init];
    [self addSubview:self.titleTF];
    [self addSubview:self.titleTF];
    [self.titleTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.top.bottom.equalTo(self);
        make.right.equalTo(self.mas_centerX);
    }];
    self.titleTF.font = Font(16);
    self.titleTF.userInteractionEnabled = NO;
    
    self.subTF = [[UITextField alloc]init];
    [self addSubview:self.subTF];
    [self.subTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.top.equalTo(self).offset(2);
        make.bottom.equalTo(self);
        make.left.equalTo(self.mas_centerX);
    }];
    self.subTF.userInteractionEnabled = NO;
    self.subTF.textAlignment = NSTextAlignmentRight;
    self.subTF.font = Font(16);
    
    return self;
}

- (void)addTarget:(id)target selector:(SEL)selector {
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:target action:selector];
    [self addGestureRecognizer:tapGes];
}

@end
