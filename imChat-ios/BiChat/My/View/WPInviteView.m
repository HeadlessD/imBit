//
//  WPInviteView.m
//  BiChat Dev
//
//  Created by iMac on 2018/9/6.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPInviteView.h"

@implementation WPInviteView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.headIV = [[UIImageView alloc]init];
    [self addSubview:self.headIV];
    [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.height.equalTo(@50);
        make.centerY.equalTo(self).offset(-30);
    }];
    self.headIV.layer.cornerRadius = 25;
    self.headIV.clipsToBounds = YES;
    
    self.headTypeIV = [[UIImageView alloc]init];
    self.headTypeIV.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.headTypeIV];
    [self.headTypeIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(23);
        make.width.height.equalTo(@20);
        make.centerY.equalTo(self).offset(-13);
    }];
    
    self.nameLabel = [[UILabel alloc]init];
    [self addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.top.equalTo(self.headIV.mas_bottom).offset(10);
        make.height.equalTo(@20);
    }];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = Font(16);
    
    self.inveteLabel = [[UILabel alloc]init];
    self.inveteLabel.hidden = YES;
    [self addSubview:self.inveteLabel];
    [self.inveteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(5);
        make.height.equalTo(@20);
    }];
    self.inveteLabel.textAlignment = NSTextAlignmentCenter;
    self.inveteLabel.font = Font(12);
    self.inveteLabel.textColor = [UIColor grayColor];
    
    
    //self.headIV.backgroundColor = [UIColor cyanColor];
    //self.nameLabel.backgroundColor = [UIColor cyanColor];
    //self.inveteLabel.backgroundColor = [UIColor cyanColor];
    return self;
}

@end
