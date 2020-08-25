//
//  WPPublicAccountDetailView.m
//  BiChat
//
//  Created by 张迅 on 2018/4/18.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPPublicAccountDetailView.h"

@implementation WPPublicAccountDetailView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    return self;
}

- (void)setViewType:(DetailViewType)viewType {
    _viewType = viewType;
    [self createUI];
}

- (void)createUI {
    self.topLineV = [[UIView alloc]init];
    [self addSubview:self.topLineV];
    self.bottomLineV.backgroundColor = RGB(0xdddddd);
    [self.topLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(self);
        make.left.equalTo(self).offset(15);
        make.height.equalTo(@1);
    }];
    self.topLineV.hidden = YES;
    
    self.bottomLineV = [[UIView alloc]init];
    [self addSubview:self.bottomLineV];
    self.bottomLineV.backgroundColor = RGB(0xdddddd);
    [self.bottomLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self);
        make.left.equalTo(self).offset(15);
        make.height.equalTo(@0.5);
    }];
    
    self.titlelabel = [[UILabel alloc]init];
    self.titlelabel.font = Font(16);
    [self addSubview:self.titlelabel];
    [self.titlelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(@(ScreenWidth / 2.0 - 15));
    }];
    
    if (self.viewType == DetailViewTypeDetail) {
        self.accessoryImageView = [[UIImageView alloc]init];
        [self addSubview:self.accessoryImageView];
        self.accessoryImageView.contentMode = UIViewContentModeCenter;
        [self.accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.top.equalTo(self);
            make.width.equalTo(@0);
        }];
        self.subLabel = [[UILabel alloc]init];
        [self addSubview:self.subLabel];
        [self.subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titlelabel.mas_right);
            make.top.bottom.equalTo(self);
            make.right.equalTo(self.accessoryImageView.mas_left).offset(-15);
        }];
        self.subLabel.textColor = RGB(0x737373);
        self.subLabel.font = Font(15);
        self.subLabel.textAlignment = NSTextAlignmentRight;
    }
    if (self.viewType == DetailViewTypeSwitch) {
        [self.titlelabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.width.equalTo(@((ScreenWidth - 30) * 0.7));
        }];
        self.mySwitch = [[UISwitch alloc]init];
        [self addSubview:self.mySwitch];
        [self.mySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-15);
        }];
        self.mySwitch.onTintColor = RGB(0x53d769);
        [self.mySwitch addTarget:self action:@selector(doSwitch:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)setAccessoryImage:(UIImage *)accessoryImage {
    if (!accessoryImage) {
        return;
    }
    _accessoryImage = accessoryImage;
    self.accessoryImageView.image = accessoryImage;
    [self.accessoryImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.right.equalTo(self);
        make.width.equalTo(@25);
    }];
    
    [self.subLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titlelabel.mas_right);
        make.top.bottom.equalTo(self);
        make.right.equalTo(self.accessoryImageView.mas_left);
    }];
}

- (void)doSwitch:(UISwitch *)mSwitch {
    if (self.SwitchBlock) {
        self.SwitchBlock(mSwitch);
    }
}

- (void)addTarget:(id)target selector:(SEL)selector {
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:target action:selector];
    [self addGestureRecognizer:tapGes];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
