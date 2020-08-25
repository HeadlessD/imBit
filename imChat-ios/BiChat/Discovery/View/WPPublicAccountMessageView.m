//
//  WPPublicAccountMessageView.m
//  BiChat
//
//  Created by iMac on 2018/7/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPPublicAccountMessageView.h"

@implementation WPPublicAccountMessageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.lineV = [[UIView alloc]init];
    [self addSubview:self.lineV];
    [self.lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self);
        make.left.equalTo(self).offset(12);
        make.height.equalTo(@0.5);
    }];
    self.lineV.backgroundColor = RGB(0xdddddd);
    
    CGFloat imageWidth = (ScreenWidth - 30) / 3.0;
    CGFloat imageHeight = imageWidth * 10 / 16;
    
    self.headIV = [[UIImageView alloc]init];
    [self addSubview:self.headIV];
    [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-12);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(@(imageWidth));
        make.height.mas_equalTo(@(imageHeight));
    }];
    self.headIV.layer.cornerRadius = 3;
    self.headIV.layer.masksToBounds = YES;
    self.headIV.contentMode = UIViewContentModeScaleAspectFill;
    
    self.titleLabel = [[UILabel alloc]init];
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(12);
        make.top.equalTo(self).offset(15);
        make.right.equalTo(self.headIV.mas_left).offset(-12);
        make.height.equalTo(@40);
    }];
    self.titleLabel.font = Font(16);
    self.titleLabel.numberOfLines = 2;
    
    self.timeLabel = [[UILabel alloc]init];
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(12);
        make.right.equalTo(self.headIV.mas_left).offset(-12);
        make.height.equalTo(@20);
        make.bottom.equalTo(self.headIV).offset(3);
    }];
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.font = Font(14);
    
    return self;
}

- (void)addTarget:(id)target action:(SEL)selector {
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:target action:selector];
    [self addGestureRecognizer:tapGes];
}

@end
